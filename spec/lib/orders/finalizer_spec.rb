# frozen_string_literal: true

require "rails_helper"

module Orders
  RSpec.describe Finalizer do
    describe "#finalize_with_payment" do
      let(:website) { FactoryBot.build_stubbed(:website) }

      it "associates the payment with the matching order and saves it" do
        payment = FactoryBot.build(:payment)
        order = FactoryBot.build_stubbed(:order, id: 123)
        stub_confirmation
        allow(Order)
          .to receive(:matching_new_payment)
          .with(payment)
          .and_return(order)

        finalizer = Finalizer.new(website)
        finalizer.finalize_with_payment(payment)

        payment.reload
        expect(payment.order_id).to eq 123
      end

      it "records discount use" do
        payment = FactoryBot.build(:payment)
        discount1 = Discount.new
        discount2 = Discount.new
        order = FactoryBot.build_stubbed(:order, id: 123, discounts: [discount1, discount2])
        allow(Order)
          .to receive(:matching_new_payment)
          .with(payment)
          .and_return(order)

        expect(discount1).to receive(:record_use)
        expect(discount2).to receive(:record_use)

        finalizer = Finalizer.new(website)
        finalizer.finalize_with_payment(payment)
      end

      context "when the order has received payment and the payment is not a " \
      "PayPal IPN" do
        let(:order) { instance_double(Order, payment_received?: true, discounts: []).as_null_object }
        let(:payment) do
          instance_double(
            Payment,
            :paypal_ipn? => false, :cart_id => "123", :order= => nil, :save => true
          )
        end

        it "sends an email confirmation" do
          allow(Order).to receive(:matching_new_payment).and_return(order)
          expect_confirmation(website, order)

          finalizer = Finalizer.new(website)
          finalizer.finalize_with_payment(payment)
        end
      end

      context "when the order is placed on a mobile app" do
        let(:order) do
          instance_double(Order, mobile_app?: true, payment_received?: true, discounts: [])
        end
        let(:payment) { instance_double(Payment).as_null_object }
        it "records a sales conversion" do
          allow(Order).to receive(:matching_new_payment).and_return(order)
          conversion = instance_double(SalesConversion)
          expect(SalesConversion).to receive(:new).with(order).and_return(conversion)
          expect(conversion).to receive(:record!)
          Finalizer.new(website).finalize_with_payment(payment)
        end
      end

      context "when the order is not placed on a mobile app" do
        let(:order) do
          instance_double(Order, mobile_app?: false, payment_received?: true, discounts: [])
        end
        let(:payment) { instance_double(Payment).as_null_object }
        it "does not record a sales conversion" do
          allow(Order).to receive(:matching_new_payment).and_return(order)
          conversion = instance_double(SalesConversion)
          allow(SalesConversion).to receive(:new).with(order).and_return(conversion)
          expect(conversion).not_to receive(:record!)
          Finalizer.new(website).finalize_with_payment(payment)
        end
      end
    end

    def expect_confirmation(website, order)
      delivery = instance_double(ActionMailer::MessageDelivery)
      expect(OrderNotifier)
        .to receive(:confirmation)
        .with(website, order)
        .and_return(delivery)
      expect(delivery).to receive(:deliver_later)
    end

    def stub_confirmation
      allow(OrderNotifier)
        .to receive(:confirmation)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: nil))
    end

    describe "#send_confirmation" do
      it "uses OrderNotifier to send a confirmation email" do
        website = Website.new
        order = Order.new
        finalizer = Finalizer.new(website)

        expect_confirmation(website, order)

        finalizer.send_confirmation(order)
      end
    end
  end
end
