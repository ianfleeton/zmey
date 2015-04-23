require 'rails_helper'

describe Admin::AdditionalProductsController do
  let(:website) { FactoryGirl.build(:website) }

  def mock_additional_product(stubs={})
    @mock_additional_product ||= double(AdditionalProduct, stubs)
  end

  def mock_product(stubs={})
    @mock_product ||= double(Product, stubs)
  end

  before do
    allow(controller).to receive(:website).and_return(website)
    logged_in_as_admin
  end

  describe 'GET new' do
    it 'assigns a new AdditionalProduct to @additional_product' do
      get 'new'
      expect(assigns(:additional_product)).to be_instance_of(AdditionalProduct)
      expect(assigns(:additional_product).new_record?).to be_truthy
    end

    it 'sets the additional product\'s product_id to the paramater' do
      get 'new', product_id: '123'
      expect(assigns(:additional_product).product_id).to eq 123
    end

    context 'when the product is valid' do
      before { allow(controller).to receive(:product_valid?).and_return(true) }

      it 'renders new' do
        get 'new'
        expect(response).to render_template('new')
      end
    end

    context 'when the product is invalid' do
      before { allow(controller).to receive(:product_valid?).and_return(false) }

      it 'redirects to the products page' do
        get 'new'
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  describe 'POST create' do
    it 'creates a new AdditionalProduct with the supplied params' do
      product = FactoryGirl.create(:product)
      params = { 'additional_product_id' => product.id, 'product_id' => product.id, 'quantity' => '1', 'selected_by_default' => true }
      post 'create', additional_product: params
      expect(AdditionalProduct.find_by(params)).to be
    end
  end

  describe 'DELETE destroy' do
    context 'when product valid' do
      let(:product) { double(Product) }

      before do
        allow(controller).to receive(:product_valid?).and_return(true)
      end

      context 'when additional product is found' do
        before do
          allow(AdditionalProduct).to receive(:find).and_return(mock_additional_product(product: product))
        end

        it 'destroys the additional product' do
          expect(mock_additional_product).to receive(:destroy)
          delete 'destroy', id: '1'
        end

        it 'redirects to the edit product page' do
          allow(mock_additional_product).to receive(:destroy)
          delete 'destroy', id: '1'
          expect(response).to redirect_to(edit_admin_product_path(product))
        end
      end
    end
  end

  def logged_in_as_admin
    allow(controller).to receive(:admin?).and_return(true)
  end
end
