require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /products/:slug" do
    context "when product inactive" do
      let(:product) { FactoryBot.create(:product, active: false) }

      it "404s" do
        get "/products/#{product.slug}"
        expect(response.status).to eq 404
      end
    end
  end
end
