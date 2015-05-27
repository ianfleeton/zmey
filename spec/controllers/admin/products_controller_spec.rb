require 'rails_helper'
require 'shared_examples_for_controllers'

describe Admin::ProductsController do
  let(:website) { FactoryGirl.build(:website) }

  def mock_product(stubs={})
    @mock_product ||= double(Product, stubs)
  end

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe "GET index" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      pending
    end
  end

  describe "GET new" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns a new product as @product" do
        allow(Product).to receive(:new).and_return(mock_product)
        get :new
        expect(assigns[:product]).to equal(mock_product)
      end
    end
  end

  describe "GET edit" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns the requested product as @product" do
        find_requested_product
        get :edit, id: '37'
        expect(assigns[:product]).to equal(mock_product)
      end
    end
  end

  describe "POST create" do
    let(:product_params) {{
      'name' => 'Product Name',
      'pricing_method' => 'quantity_based',
      'sku' => 'sku',
    }}
    let(:valid_params) { { 'product' => product_params } }

    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns a newly created product as @product" do
        post :create, valid_params
        expect(Product.exists?(product_params)).to be_truthy
      end

      describe "with valid params" do
        before do
          allow(Product).to receive(:new).with(valid_params['product']).and_return(mock_product(:website_id= => website.id, save: true))
        end

        it "redirects to the new product page" do
          post :create, valid_params
          expect(response).to redirect_to(new_admin_product_path)
        end
      end

      describe "with invalid params" do
        before do
          allow(Product).to receive(:new).with({'these' => 'params'}).and_return(mock_product(:website_id= => website.id, save: false))
        end

        it "re-renders the 'new' template" do
          allow(Product).to receive(:new).and_return(mock_product(:website_id= => website.id, :save => false))
          post :create, valid_params
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe "PUT update" do
    let(:valid_params) { { 'id' => '37', 'product' => { 'name' => 'Product Name' } } }

    context "when logged in as admin" do
      before { logged_in_as_admin }

      describe "with valid params" do
        it "updates the requested product" do
          find_requested_product
          expect(mock_product).to receive(:update_attributes).with(valid_params['product'])
          allow(mock_product).to receive(:update_extra)
          put :update, valid_params
        end

        it "assigns the requested product as @product" do
          allow(Product).to receive(:find_by).and_return(mock_product(update_attributes: true))
          allow(mock_product).to receive(:update_extra)
          put :update, valid_params
          expect(assigns(:product)).to equal(mock_product)
        end

        it "redirects to the edit product page again" do
          allow(Product).to receive(:find_by).and_return(mock_product(update_attributes: true))
          allow(mock_product).to receive(:update_extra)
          put :update, valid_params
          expect(response).to redirect_to(edit_admin_product_path(mock_product))
        end
      end

      describe "with invalid params" do
        it "updates the requested product" do
          find_requested_product
          expect(mock_product).to receive(:update_attributes).with(valid_params['product'])
          allow(mock_product).to receive(:update_extra)
          put :update, valid_params
        end

        it "assigns the product as @product" do
          allow(Product).to receive(:find_by).and_return(mock_product(update_attributes: false))
          allow(mock_product).to receive(:update_extra)
          put :update, valid_params
          expect(assigns(:product)).to equal(mock_product)
        end

        it "re-renders the 'edit' template" do
          allow(Product).to receive(:find_by).and_return(mock_product(update_attributes: false))
          allow(mock_product).to receive(:update_extra)
          put :update, valid_params
          expect(response).to render_template('edit')
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
        delete :destroy, id: '37'
      end

      it "redirects to the products list" do
        allow(Product).to receive(:find_by).and_return(mock_product(destroy: true))
        delete :destroy, id: '1'
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  def find_requested_product(stubs={})
    expect(Product).to receive(:find_by).with(id: '37').and_return(mock_product(stubs))
  end
end
