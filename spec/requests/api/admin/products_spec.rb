require 'rails_helper'

describe 'Admin products API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    context 'with products' do
      before do
        @product1 = FactoryGirl.create(:product)
        @product2 = FactoryGirl.create(:product)
      end

      it 'returns all products' do
        get '/api/admin/products'

        products = JSON.parse(response.body)

        expect(products['products'].length).to eq 2
        expect(products['products'][0]['id']).to eq @product1.id
        expect(products['products'][0]['sku']).to eq @product1.sku
        expect(products['products'][0]['name']).to eq @product1.name
      end

      it 'returns 200 OK' do
        get '/api/admin/products'
        expect(response.status).to eq 200
      end
    end

    context 'with no products' do
      it 'returns 200 OK' do
        get '/api/admin/products'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get '/api/admin/products'
        products = JSON.parse(response.body)
        expect(products['products'].length).to eq 0
      end
    end
  end

  describe 'GET show' do
    context 'when product found' do
      before do
        @product = FactoryGirl.create(:product)
      end

      it 'returns 200 OK' do
        get api_admin_product_path(@product)
        expect(response.status).to eq 200
      end
    end

    context 'when no product' do
      it 'returns 404 Not Found' do
        get '/api/admin/products/0'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST create' do
    let(:name)     { SecureRandom.hex }
    let(:sku)      { SecureRandom.hex }
    let(:tax_type) { Product::INC_VAT }
    let(:weight)   { 1.234 }
    let(:basic_params) {{
      allow_fractional_quantity: true,
      name: name,
      sku: sku,
      tax_type: tax_type,
      weight: weight
    }}

    it 'inserts a new product' do
      post '/api/admin/products', product: basic_params
      expect(Product.find_by(basic_params)).to be
    end

    it 'associates product with nominal code' do
      nominal_code = FactoryGirl.create(:nominal_code, website_id: @website.id)
      params = basic_params.merge(nominal_code: nominal_code.code)
      post '/api/admin/products', product: params
      expect(Product.last.nominal_code).to eq nominal_code
    end

    it 'returns 422 if product cannot be created' do
      post '/api/admin/products', product: {name: 'is not enough'}
      expect(status).to eq 422
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all products' do
      product_1 = FactoryGirl.create(:product)
      product_2 = FactoryGirl.create(:product)

      delete '/api/admin/products'

      expect(Product.find_by(id: product_1.id)).not_to be
      expect(Product.find_by(id: product_2.id)).not_to be
    end

    it 'responds with 204 No Content' do
      delete '/api/admin/products'

      expect(status).to eq 204
    end
  end
end
