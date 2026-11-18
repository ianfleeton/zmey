require "rails_helper"

RSpec.describe "Minimum order value", type: :request do
  before { FactoryBot.create(:website) }

  describe "checkout" do
    def basket_with_item(price)
      product = FactoryBot.create(:product, price: price)
      post "/basket/add", params: {product_id: product.id}
    end

    it "sends customers back to the basket when goods total under £2" do
      basket_with_item(1)
      get checkout_path
      expect(response).to redirect_to(basket_path)
      expect(flash[:notice]).to eq Checkout::MinimumOrderValue.message
    end

    it "lets customers check out from £2" do
      basket_with_item(2)
      get checkout_path
      expect(flash[:notice]).not_to eq Checkout::MinimumOrderValue.message
    end
  end

  describe "Stripe payment intents" do
    let(:order) { FactoryBot.create(:order, :unpaid) }

    before do
      FactoryBot.create(:order_line, order: order, product_price: 1, product_name: "Cheap")
      allow(Order).to receive(:current!).and_return(order)
    end

    it "refuses to take payment for goods totalling under £2" do
      expect(Payments::StripePaymentIntent).not_to receive(:new)
      post payments_stripe_payment_intents_path,
        params: {payment_method_id: "pm_123", idempotency_key: "idem"}
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to include(Checkout::MinimumOrderValue.message)
    end
  end
end
