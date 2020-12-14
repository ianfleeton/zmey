require "rails_helper"

RSpec.describe OrdersHelper, type: :helper do
  include ProductsHelper

  describe "#order_date_label" do
    let(:status) { Enums::PaymentStatus::PAYMENT_RECEIVED }
    let(:order) { Order.new(invoiced_at: invoiced_at, status: status) }
    subject { helper.order_date_label(order) }

    context "invoiced_at is set" do
      let(:invoiced_at) { Time.current }
      it { should eq "Invoice Date" }
    end

    context "invoiced_at is nil" do
      let(:invoiced_at) { nil }
      it { should eq "Order Date" }

      context "order is a quote" do
        let(:status) { Enums::PaymentStatus::QUOTE }
        it { should eq "Quotation Date" }
      end
    end
  end

  describe "#order_formatted_time" do
    let(:order) do
      Order.new(
        invoiced_at: invoiced_at,
        created_at: created_at
      )
    end
    subject { helper.order_formatted_time(order) }

    context "invoiced_at is set" do
      let(:created_at) { DateTime.new(2016, 12, 9, 12, 52) }
      let(:invoiced_at) { DateTime.new(2016, 12, 10, 10, 25) }
      it { should eq "10 December 2016 - 10:25 am" }
    end

    context "invoiced_at is nil" do
      let(:created_at) { DateTime.new(2016, 12, 9, 12, 52) }
      let(:invoiced_at) { nil }
      it { should eq " 9 December 2016 - 12:52 pm" }
    end

    context "neither invoiced_at nor created_at is set" do
      let(:created_at) { nil }
      let(:invoiced_at) { nil }
      it { should eq "" }
    end
  end

  describe "#sage_pay_form_url" do
    it "returns a live URL when test_mode false" do
      expect(sage_pay_form_url(false)).to eq(
        "https://live.sagepay.com/gateway/service/vspform-register.vsp"
      )
    end

    it "returns a test URL when test_mode true" do
      expect(sage_pay_form_url(true)).to eq(
        "https://test.sagepay.com/gateway/service/vspform-register.vsp"
      )
    end
  end

  describe "#record_sales_conversion" do
    let(:order) { FactoryBot.create(:order) }

    before do
      without_partial_double_verification do
        allow(view).to receive(:website).and_return(Website.new)
      end
    end

    it "renders the Google Analytics sales conversion code" do
      expect(view).to receive(:render).with(
        hash_including(
          partial: "orders/google_sales_conversion"
        ), anything
      ).and_call_original
      record_sales_conversion(order)
    end

    it "tells SalesConversion to record conversion for the order" do
      conversion = instance_double(Orders::SalesConversion)
      expect(Orders::SalesConversion).to receive(:new).with(order).and_return(conversion)
      expect(conversion).to receive(:record!)
      record_sales_conversion(order)
    end
  end

  describe "#delivery_amount_description" do
    it "returns '[Awating quotation]' for orders needing a shipping quote" do
      order = Order.new(status: Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE)
      expect(delivery_amount_description(order)).to eq "[Awaiting quotation]"
    end

    it "returns 'Free' for zero shipping orders" do
      order = Order.new(status: Enums::PaymentStatus::WAITING_FOR_PAYMENT)
      expect(delivery_amount_description(order)).to eq "Free"
    end

    it "returns the formatted shipping amount for all other orders" do
      order = Order.new(
        status: Enums::PaymentStatus::WAITING_FOR_PAYMENT,
        shipping_amount: 10
      )
      expect(delivery_amount_description(order)).to eq "£10.00"
    end
  end
end
