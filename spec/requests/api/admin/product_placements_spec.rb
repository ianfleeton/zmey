require 'rails_helper'

describe 'Admin product placements API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    it 'inserts a new product placement' do
      page = FactoryGirl.create(:page)
      product = FactoryGirl.create(:product)
      post '/api/admin/product_placements', product_placement: {page_id: page.id, product_id: product.id}
      expect(ProductPlacement.find_by(page_id: page.id, product_id: product.id)).to be
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all product placements' do
      product = FactoryGirl.create(:product)
      page = FactoryGirl.create(:page)
      placement = ProductPlacement.create!(page: page, product: product)

      delete '/api/admin/product_placements'

      expect(ProductPlacement.find_by(id: placement.id)).not_to be
    end

    it 'responds with 204 No Content' do
      delete '/api/admin/product_placements'

      expect(status).to eq 204
    end
  end
end
