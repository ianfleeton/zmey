require "rails_helper"

module Admin
  RSpec.describe AdditionalProductsController, type: :controller do
    let(:website) { FactoryBot.build(:website) }

    def mock_additional_product(stubs = {})
      @mock_additional_product ||= double(AdditionalProduct, stubs)
    end

    def mock_product(stubs = {})
      @mock_product ||= double(Product, stubs)
    end

    before do
      allow(controller).to receive(:website).and_return(website)
      logged_in_as_admin
    end

    describe "GET new" do
      context "when the product is invalid" do
        before { allow(controller).to receive(:product_valid?).and_return(false) }

        it "redirects to the products page" do
          get "new"
          expect(response).to redirect_to(admin_products_path)
        end
      end
    end

    describe "POST create" do
      it "creates a new AdditionalProduct with the supplied params" do
        product = FactoryBot.create(:product)
        params = {"additional_product_id" => product.id, "product_id" => product.id, "quantity" => "1", "selected_by_default" => true}
        post "create", params: {additional_product: params}
        expect(AdditionalProduct.find_by(params)).to be
      end
    end

    describe "DELETE destroy" do
      context "when product valid" do
        let(:product) { double(Product) }

        before do
          allow(controller).to receive(:product_valid?).and_return(true)
        end

        context "when additional product is found" do
          before do
            allow(AdditionalProduct).to receive(:find).and_return(mock_additional_product(product: product))
          end

          it "destroys the additional product" do
            expect(mock_additional_product).to receive(:destroy)
            delete "destroy", params: {id: "1"}
          end

          it "redirects to the edit product page" do
            allow(mock_additional_product).to receive(:destroy)
            delete "destroy", params: {id: "1"}
            expect(response).to redirect_to(edit_admin_product_path(product))
          end
        end
      end
    end
  end
end
