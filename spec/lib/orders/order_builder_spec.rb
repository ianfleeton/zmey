# frozen_string_literal: true

require "rails_helper"

module Orders
  RSpec.describe OrderBuilder do
    describe "#initialize" do
      it "recycles a previous unpaid order if one exists" do
        expect(Orders::Recycler)
          .to receive(:new_or_recycled).with(123).and_call_original
        OrderBuilder.new(123)
      end
    end

    describe "#add_basket" do
      it "adds the basket to the order" do
        basket = Basket.new
        expect_any_instance_of(Order).to receive(:add_basket).with(basket)
        OrderBuilder.build(123) { |builder|
          builder.add_basket basket
        }
      end
    end

    describe "#add_discount_lines" do
      it "adds the discount lines to the order" do
        discount_lines = [DiscountLine.new(nil, {})]
        expect_any_instance_of(Order).to receive(:add_discount_lines)
          .with(discount_lines)
        OrderBuilder.build(123) { |builder|
          builder.add_discount_lines discount_lines
        }
      end

      it "adds discount uses to the order" do
        order = FactoryBot.create(:order)
        ob = OrderBuilder.new(order.id)
        discount1 = FactoryBot.build(:discount)
        discount2 = FactoryBot.build(:discount)
        ob.add_discount_lines([
          DiscountLine.new(discount1, {}),
          DiscountLine.new(discount1, {}),
          DiscountLine.new(discount2, {})
        ])
        expect(ob.order.discount_uses.length).to eq 2
        expect(ob.order.discount_uses.first.discount).to eq discount1
        expect(ob.order.discount_uses.last.discount).to eq discount2
      end
    end

    describe "#user=" do
      it "records a non-persisted user as not logged in" do
        user = User.new
        ob = OrderBuilder.new(123)
        ob.user = user
        expect(ob.order.user).to eq user
        expect(ob.order.logged_in?).to be_falsey
      end

      it "records a nil user as not logged in" do
        ob = OrderBuilder.new(123)
        ob.user = nil
        expect(ob.order.user).to be_nil
        # Check for false instead of falsiness is intentional befcause +nil+ is
        # not a valid value for logged_in.
        expect(ob.order.logged_in).to eq false
      end

      it "records a persisted user as logged in" do
        user = FactoryBot.create(:user)
        ob = OrderBuilder.new(123)
        ob.user = user
        expect(ob.order.user).to eq user
        expect(ob.order.logged_in?).to be_truthy
      end
    end

    describe "#requires_delivery_address=" do
      it "records requires_delivery_address" do
        requires_delivery_address = [true, false].sample
        ob = OrderBuilder.new(123)
        ob.requires_delivery_address = requires_delivery_address
        expect(ob.order.requires_delivery_address).to eq requires_delivery_address
      end
    end

    describe "#add_shipping_details" do
      it "records shipping details" do
        order = OrderBuilder.build(123) { |builder|
          builder.add_shipping_details(
            net_amount: 5.95, vat_amount: 1.19, method: "Royal Mail",
            quote_needed: true
          )
        }
        expect(order.shipping_amount).to eq 5.95
        expect(order.shipping_vat_amount).to eq 1.19
        expect(order.shipping_method).to eq "Royal Mail"
        expect(order.status).to eq Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE
      end
    end

    describe "#dispatch_date=" do
      it "records dispatch date" do
        monday = Date.new(2017, 7, 3)
        order = OrderBuilder.build(123) { |builder|
          builder.dispatch_date = monday
        }
        expect(order.dispatch_date).to eq monday
      end
    end

    describe "#delivery_date=" do
      it "records dispatch date" do
        tuesday = Date.new(2017, 7, 4)
        order = OrderBuilder.build(123) { |builder|
          builder.delivery_date = tuesday
        }
        expect(order.delivery_date).to eq tuesday
      end
    end

    describe "#billing_address=" do
      it "copies the billing address to the order" do
        ob = OrderBuilder.new(123)
        billing_address = Address.new
        expect_any_instance_of(Order).to receive(:copy_billing_address)
          .with(billing_address)
        ob.billing_address = billing_address
      end
    end

    describe "#delivery_address=" do
      it "copies the delivery address to the order" do
        ob = OrderBuilder.new(123)
        delivery_address = Address.new
        expect_any_instance_of(Order).to receive(:copy_delivery_address)
          .with(delivery_address)
        ob.delivery_address = delivery_address
      end
    end

    describe "#add_client_details" do
      let(:builder) { OrderBuilder.new(123) }
      let(:order) { builder.order }

      before do
        builder.add_client_details(
          ip_address: "0.0.0.0", user_agent: "Edge", platform: "ios"
        )
      end

      it "records the ip address" do
        expect(order.client.ip_address).to eq "0.0.0.0"
      end

      it "records the user agent" do
        expect(order.client.user_agent).to eq "Edge"
      end

      it "records the client platform" do
        expect(order.client.platform).to eq "ios"
      end
    end

    describe "#prepare_for_payment" do
      it "sets the order status to waiting for payment" do
        ob = OrderBuilder.new(123)
        ob.prepare_for_payment
        expect(ob.order.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
      end

      context "when the order needs a shipping quote" do
        it "leaves the order status untouched" do
          ob = OrderBuilder.new(123)
          ob.add_shipping_details(
            net_amount: 0, vat_amount: 0, method: "", quote_needed: true
          )
          ob.prepare_for_payment
          expect(ob.order.status).to eq Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE
        end
      end
    end
  end
end
