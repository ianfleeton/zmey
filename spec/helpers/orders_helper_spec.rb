require "rails_helper"

RSpec.describe OrdersHelper, type: :helper do
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
