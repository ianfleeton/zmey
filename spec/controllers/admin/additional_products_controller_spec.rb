require 'spec_helper'

describe Admin::AdditionalProductsController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_additional_product(stubs={})
    @mock_additional_product ||= mock_model(AdditionalProduct, stubs)
  end

  def mock_product(stubs={})
    @mock_product ||= mock_model(Product, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    logged_in_as_admin
    website.stub(:private?).and_return(false)
  end

  describe 'GET new' do
    it 'assigns a new AdditionalProduct to @additional_product' do
      AdditionalProduct.stub(:new).and_return(mock_additional_product.as_null_object)
      get 'new'
      expect(assigns(:additional_product)).to eq mock_additional_product
    end

    it 'sets the additional product\'s product_id to the paramater' do
      get 'new', product_id: '123'
      expect(assigns(:additional_product).product_id).to eq 123
    end

    context 'when the product is valid' do
      before { controller.stub(:product_valid?).and_return(true) }

      it 'renders new' do
        get 'new'
        expect(response).to render_template('new')
      end
    end

    context 'when the product is invalid' do
      before { controller.stub(:product_valid?).and_return(false) }

      it 'redirects to the products page' do
        get 'new'
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  describe 'POST create' do
    it 'creates a new AdditionalProduct with the supplies params' do
      params = { 'additional_product_id' => '1', 'product_id' => '2', 'selected_by_default' => true }
      AdditionalProduct.should_receive(:new).with(params)
        .and_return(mock_additional_product.as_null_object)
      post 'create', additional_product: params
    end
  end

  describe 'DELETE destroy' do
    context 'when product valid' do
      let(:product) { mock_model(Product) }

      before do
        controller.stub(:product_valid?).and_return(true)
      end

      context 'when additional product is found' do
        before do
          AdditionalProduct.stub(:find).and_return(mock_additional_product(product: product))
        end

        it 'destroys the additional product' do
          mock_additional_product.should_receive(:destroy)
          delete 'destroy', id: '1'
        end

        it 'redirects to the edit product page' do
          delete 'destroy', id: '1'
          expect(response).to redirect_to(edit_admin_product_path(product))
        end
      end
    end
  end

  def logged_in_as_admin
    controller.stub(:admin?).and_return(true)
  end
end