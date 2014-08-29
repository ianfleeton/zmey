require 'rails_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin products API' do
  before do
    prepare_api_website
    allow_any_instance_of(Api::Admin::AdminController).to receive(:authenticated_api_key).and_return(@api_key)
  end

  describe 'GET index' do
    context 'with products' do
      before do
        @product1 = FactoryGirl.create(:product, website_id: @website.id)
        @product2 = FactoryGirl.create(:product)
      end

      it 'returns products for the website' do
        get 'api/admin/products'

        products = JSON.parse(response.body)

        expect(products['products'].length).to eq 1
        expect(products['products'][0]['id']).to eq @product1.id
        expect(products['products'][0]['sku']).to eq @product1.sku
        expect(products['products'][0]['name']).to eq @product1.name
      end

      it 'returns 200 OK' do
        get 'api/admin/products'
        expect(response.status).to eq 200
      end
    end

    context 'with no products' do
      it 'returns 200 OK' do
        get 'api/admin/products'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get 'api/admin/products'
        products = JSON.parse(response.body)
        expect(products['products'].length).to eq 0
      end
    end
  end

  describe 'GET show' do
    context 'when product found' do
      before do
        @product = FactoryGirl.create(:product, website_id: @website.id)
      end

      it 'returns 200 OK' do
        get api_admin_product_path(@product)
        expect(response.status).to eq 200
      end
    end

    context 'when no product' do
      it 'returns 404 Not Found' do
        get 'api/admin/products/0'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST create' do
    it 'inserts a new product into the website' do
      name = SecureRandom.hex
      sku = SecureRandom.hex
      tax_type = Product::INC_VAT
      weight = 1.234
      post 'api/admin/products', product: {name: name, sku: sku, tax_type: tax_type, weight: weight}
      expect(Product.find_by(sku: sku, tax_type: tax_type, weight: weight, website: @website)).to be
    end

    it 'returns 422 if product cannot be created' do
      post 'api/admin/products', product: {name: 'is not enough'}
      expect(status).to eq 422
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all products in the website' do
      product_1 = FactoryGirl.create(:product, website_id: @website.id)
      product_2 = FactoryGirl.create(:product, website_id: @website.id)
      product_3 = FactoryGirl.create(:product)

      delete 'api/admin/products'

      expect(Product.find_by(id: product_1.id)).not_to be
      expect(Product.find_by(id: product_2.id)).not_to be
      expect(Product.find_by(id: product_3.id)).to be
    end

    it 'responds with 204 No Content' do
      delete 'api/admin/products'

      expect(status).to eq 204
    end
  end
end
