require 'rails_helper'

RSpec.describe 'Admin product groups API', type: :request do
  before do
    prepare_api_website
  end

  describe 'GET show' do
    context 'when product group found' do
      let(:product_group) { FactoryGirl.create(:product_group) }

      it 'returns 200 OK' do
        get api_admin_product_group_path(product_group)
        expect(response.status).to eq 200
      end

      it 'includes its attributes' do
        get api_admin_product_group_path(product_group)
        parsed = JSON.parse(response.body)['product_group']
        expect(parsed['id']).to eq product_group.id
        expect(parsed['href']).to eq api_admin_product_group_url(product_group)
        expect(parsed['name']).to eq product_group.name
        expect(parsed['location']).to eq product_group.location
      end

      it 'includes products' do
        product = FactoryGirl.create(:product)
        product_group.products << product
        product_group.save
        get api_admin_product_group_path(product_group)
        expect(JSON.parse(response.body)['product_group']['products'][0]['href']).to eq api_admin_product_url(product)
      end
    end

    context 'when no product group' do
      it 'returns 404 Not Found' do
        get '/api/admin/product_groups/0'
        expect(response.status).to eq 404
      end
    end
  end
end
