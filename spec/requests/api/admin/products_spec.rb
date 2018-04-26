require 'rails_helper'
require_relative 'shared_examples/api_pagination.rb'

describe 'Admin products API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    let(:json)              { JSON.parse(response.body) }
    let(:num_items)         { 1 }
    let(:page)              { nil }
    let(:page_size)         { nil }
    let(:default_page_size) { 3 }

    before do
      # Reduce default page size for spec execution speed.
      allow_any_instance_of(Api::Admin::ProductsController)
        .to receive(:default_page_size)
        .and_return(default_page_size)

      num_items.times do |x|
        FactoryBot.create(
          :product,
          updated_at: Date.today - x.days # affects ordering
        )
      end
      @product1 = Product.first
      get '/api/admin/products', params: { page: page, page_size: page_size }
    end

    context 'with products' do
      it 'returns all products' do
        products = JSON.parse(response.body)

        expect(products['products'].length).to eq 1
        expect(products['products'][0]['id']).to eq @product1.id
        expect(products['products'][0]['sku']).to eq @product1.sku
        expect(products['products'][0]['name']).to eq @product1.name
      end

      it 'returns 200 OK' do
        expect(response.status).to eq 200
      end

      it 'returns the current time in now' do
        expect(Time.parse(JSON.parse(response.body)['now'])).to be_instance_of(Time)
      end

      it 'states total count of products' do
        expect(JSON.parse(response.body)['count']).to eq 1
      end
    end

    context 'getting products updated since' do
      let(:num_items) { 0 }
      let!(:recently_updated) { FactoryBot.create(:product, updated_at: Date.new(2015, 1, 31)) }
      let!(:updated_ages_ago) { FactoryBot.create(:product, updated_at: Date.new(2013, 3, 14)) }

      before { get '/api/admin/products?updated_since=2014-03-20T10:30:11.123Z' }

      subject { json['products'] }

      it 'returns 1 product' do
        expect(subject.length).to eq 1
      end

      it 'returns the recently updated product' do
        expect(subject[0]['id']).to eq recently_updated.id
      end
    end

    it_behaves_like 'an API paginator', class: Product

    context 'with no products' do
      let(:num_items) { 0 }

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
      let(:weight) { 1.23 }
      let(:product) { FactoryBot.create(:product, weight: weight) }

      it 'returns 200 OK' do
        get api_admin_product_path(product)
        expect(response.status).to eq 200
      end

      it 'includes basic attributes' do
        get api_admin_product_path(product)
        product_obj = JSON.parse(response.body)['product']
        expect(product_obj['weight']).to eq weight.to_s
      end

      it 'includes extra attributes' do
        ExtraAttribute.create!(attribute_name: 'length', class_name: Product)
        product.length = '1500'
        product.save
        get api_admin_product_path(product)
        expect(JSON.parse(response.body)['product']['length']).to eq '1500'
      end

      it 'includes product groups' do
        group = FactoryBot.create(:product_group)
        product.product_groups << group
        product.save
        get api_admin_product_path(product)
        expect(JSON.parse(response.body)['product']['product_groups'][0]['href']).to eq api_admin_product_group_url(group)
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
    let(:extra)    { '{"some": "data"}' }
    let(:name)     { SecureRandom.hex }
    let(:price)    { 2.34 }
    let(:rrp)      { 3.45 }
    let(:sku)      { SecureRandom.hex }
    let(:submit_to_google) { [true, false].sample }
    let(:tax_type) { Product::INC_VAT }
    let(:weight)   { 1.234 }
    let(:basic_params) {{
      allow_fractional_quantity: true,
      extra: extra,
      name: name,
      price: price,
      pricing_method: 'quantity_based',
      rrp: rrp,
      sku: sku,
      submit_to_google: submit_to_google,
      tax_type: tax_type,
      weight: weight
    }}

    it 'inserts a new product' do
      post '/api/admin/products', params: { product: basic_params }
      expect(Product.find_by(basic_params)).to be
    end

    it 'associates product with a sole product group' do
      group = FactoryBot.create(:product_group, name: 'Special Offers')
      params = basic_params.merge(
        product_group: 'Special Offers'
      )
      post '/api/admin/products', params: { product: params }
      expect(Product.last.product_groups.first).to eq group
    end

    it 'returns 422 if product cannot be created' do
      post '/api/admin/products', params: { product: { name: 'is not enough' } }
      expect(status).to eq 422
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all products' do
      product_1 = FactoryBot.create(:product)
      product_2 = FactoryBot.create(:product)

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
