require 'spec_helper'
require 'shared_examples_for_controllers'

describe ProductsController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_product(stubs={})
    @mock_product ||= mock_model(Product, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
    website.stub(:vat_number).and_return('')
  end

  describe "GET index" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it_behaves_like 'a website owned objects finder', :product
    end
  end

  describe "GET show" do
    it "assigns the requested product as @product" do
      website.stub(:name).and_return('Website')
      find_requested_product(page_title: '', name: '', meta_description: '')
      get :show, id: '37'
      expect(assigns[:product]).to equal(mock_product)
    end
  end

  describe "GET new" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns a new product as @product" do
        Product.stub(:new).and_return(mock_product)
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
    let(:valid_params) { { 'product' => { 'name' => 'Product Name' } } }

    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns a newly created product as @product" do
        Product.stub(:new).with(valid_params['product']).and_return(mock_product(:website_id= => website.id, save: true))
        post :create, valid_params
        expect(assigns[:product]).to equal(mock_product)
      end

      describe "with valid params" do
        before do
          Product.stub(:new).with(valid_params['product']).and_return(mock_product(:website_id= => website.id, save: true))
        end

        it "redirects to the new product page" do
          post :create, valid_params
          expect(response).to redirect_to(new_product_path)
        end
      end

      describe "with invalid params" do
        before do
          Product.stub(:new).with({'these' => 'params'}).and_return(mock_product(:website_id= => website.id, save: false))
        end

        it "re-renders the 'new' template" do
          Product.stub(:new).and_return(mock_product(:website_id= => website.id, :save => false))
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
          mock_product.should_receive(:update_attributes).with(valid_params['product'])
          put :update, valid_params
        end

        it "assigns the requested product as @product" do
          Product.stub(:find_by).and_return(mock_product(update_attributes: true))
          put :update, valid_params
          expect(assigns(:product)).to equal(mock_product)
        end

        it "redirects to the product" do
          Product.stub(:find_by).and_return(mock_product(update_attributes: true))
          put :update, valid_params
          expect(response).to redirect_to(product_url(mock_product))
        end
      end

      describe "with invalid params" do
        it "updates the requested product" do
          find_requested_product
          mock_product.should_receive(:update_attributes).with(valid_params['product'])
          put :update, valid_params
        end

        it "assigns the product as @product" do
          Product.stub(:find_by).and_return(mock_product(update_attributes: false))
          put :update, valid_params
          expect(assigns(:product)).to equal(mock_product)
        end

        it "re-renders the 'edit' template" do
          Product.stub(:find_by).and_return(mock_product(update_attributes: false))
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
        mock_product.should_receive(:destroy)
        delete :destroy, id: '37'
      end

      it "redirects to the products list" do
        Product.stub(:find_by).and_return(mock_product(destroy: true))
        delete :destroy, id: '1'
        expect(response).to redirect_to(products_url)
      end
    end
  end

  def find_requested_product(stubs={})
    Product.should_receive(:find_by).with(id: '37', website_id: website.id).and_return(mock_product(stubs))
  end
end
