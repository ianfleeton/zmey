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
      allow(view).to receive(:website).and_return(Website.new)
    end

    it "renders the Google Analytics sales conversion code" do
      expect(view).to receive(:render).with(hash_including(partial: "orders/google_ecommerce_tracking"), anything).and_call_original
      record_sales_conversion(order)
    end

    it "tells the order to record sales conversion" do
      expect(order).to receive(:record_sales_conversion!)
      record_sales_conversion(order)
    end
  end
end
