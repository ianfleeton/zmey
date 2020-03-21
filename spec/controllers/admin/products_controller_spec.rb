require "rails_helper"

RSpec.describe Admin::ProductsController, type: :controller do
  def mock_product(stubs = {})
    @mock_product ||= double(Product, stubs)
  end

  describe "GET index" do
  end

  describe "GET new" do
    context "when logged in as admin" do
      before { logged_in_as_admin }
    end
  end

  describe "GET edit" do
  end

  describe "POST create" do
    let(:product_params) {
      {
        "name" => "Product Name",
        "pricing_method" => "quantity_based",
        "sku" => "sku"
      }
    }
    let(:valid_params) { {"product" => product_params} }

    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "creates a new product with the given params" do
        post :create, params: valid_params
        expect(Product.exists?(product_params)).to be_truthy
      end

      describe "with valid params" do
        before do
          allow(Product).to receive(:new).and_return(mock_product(save: true))
        end

        it "redirects to the new product page" do
          post :create, params: valid_params
          expect(response).to redirect_to(new_admin_product_path)
        end
      end
    end
  end

  describe "PUT update" do
    let(:valid_params) { {"id" => "37", "product" => {"name" => "Product Name"}} }

    context "when logged in as admin" do
      before { logged_in_as_admin }

      describe "with valid params" do
        it "updates the requested product" do
          find_requested_product
          expect(mock_product).to receive(:update_attributes)
          allow(mock_product).to receive(:update_extra)
          put :update, params: valid_params
        end

        it "redirects to the edit product page again" do
          allow(Product).to receive(:find_by).and_return(mock_product(update_attributes: true))
          allow(mock_product).to receive(:update_extra)
          put :update, params: valid_params
          expect(response).to redirect_to(edit_admin_product_path(mock_product))
        end
      end

      describe "with invalid params" do
        it "updates the requested product" do
          find_requested_product
          expect(mock_product).to receive(:update_attributes)
          allow(mock_product).to receive(:update_extra)
          put :update, params: valid_params
        end
      end
    end
  end

  describe "DELETE destroy" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "destroys the requested product" do
        find_requested_product
        expect(mock_product).to receive(:destroy)
        delete :destroy, params: {id: "37"}
      end

      it "redirects to the products list" do
        allow(Product).to receive(:find_by).and_return(mock_product(destroy: true))
        delete :destroy, params: {id: "1"}
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  def find_requested_product(stubs = {})
    expect(Product).to receive(:find_by).with(id: "37").and_return(mock_product(stubs))
  end
end
