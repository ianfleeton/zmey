require 'spec_helper'

describe ProductsController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_product(stubs={})
    @mock_product ||= mock_model(Product, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe "GET index" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns all products as @products" do
        controller.should_receive(:admin?)
        Product.stub(:all).and_return([mock_product])
        get :index
        assigns(:products).should eq([mock_product])
      end
    end
  end

  describe "GET show" do
    it "assigns the requested product as @product" do
      find_requested_product(:page_title => '', :name => '', :meta_description => '')
      get :show, :id => "37"
      assigns[:product].should equal(mock_product)
    end
  end

  describe "GET new" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns a new product as @product" do
        Product.stub(:new).and_return(mock_product)
        get :new
        assigns[:product].should equal(mock_product)
      end
    end
  end

  describe "GET edit" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      it "assigns the requested product as @product" do
        find_requested_product
        get :edit, :id => "37"
        assigns[:product].should equal(mock_product)
      end
    end
  end

  describe "POST create" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      describe "with valid params" do
        it "assigns a newly created product as @product" do
          Product.stub(:new).with({'these' => 'params'}).and_return(mock_product(:website_id= => website.id, :save => true))
          post :create, :product => {:these => 'params'}
          assigns[:product].should equal(mock_product)
        end

        it "redirects to the new product page" do
          Product.stub(:new).and_return(mock_product(:website_id= => website.id, :save => true))
          post :create, :product => {}
          response.should redirect_to(new_product_path)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved product as @product" do
          Product.stub(:new).with({'these' => 'params'}).and_return(mock_product(:website_id= => website.id, :save => false))
          post :create, :product => {:these => 'params'}
          assigns[:product].should equal(mock_product)
        end

        it "re-renders the 'new' template" do
          Product.stub(:new).and_return(mock_product(:website_id= => website.id, :save => false))
          post :create, :product => {}
          response.should render_template('new')
        end
      end
    end
  end

  describe "PUT update" do
    context "when logged in as admin" do
      before { logged_in_as_admin }

      describe "with valid params" do
        it "updates the requested product" do
          find_requested_product
          mock_product.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :product => {:these => 'params'}
        end

        it "assigns the requested product as @product" do
          Product.stub(:find_by_id_and_website_id).and_return(mock_product(:update_attributes => true))
          put :update, :id => "1"
          assigns[:product].should equal(mock_product)
        end

        it "redirects to the product" do
          Product.stub(:find_by_id_and_website_id).and_return(mock_product(:update_attributes => true))
          put :update, :id => "1"
          response.should redirect_to(product_url(mock_product))
        end
      end

      describe "with invalid params" do
        it "updates the requested product" do
          find_requested_product
          mock_product.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, :id => "37", :product => {:these => 'params'}
        end

        it "assigns the product as @product" do
          Product.stub(:find_by_id_and_website_id).and_return(mock_product(:update_attributes => false))
          put :update, :id => "1"
          assigns[:product].should equal(mock_product)
        end

        it "re-renders the 'edit' template" do
          Product.stub(:find_by_id_and_website_id).and_return(mock_product(:update_attributes => false))
          put :update, :id => "1"
          response.should render_template('edit')
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
        delete :destroy, :id => "37"
      end

      it "redirects to the products list" do
        Product.stub(:find_by_id_and_website_id).and_return(mock_product(:destroy => true))
        delete :destroy, :id => "1"
        response.should redirect_to(products_url)
      end
    end
  end

  def logged_in_as_admin
    controller.stub(:admin?).and_return(true)
  end

  def find_requested_product(stubs={})
    Product.should_receive(:find_by_id_and_website_id).with("37", website.id).and_return(mock_product(stubs))
  end
end
