require 'rails_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin product placements API' do
  before do
    prepare_api_website
    allow_any_instance_of(Api::Admin::AdminController).to receive(:authenticated_api_key).and_return(@api_key)
  end

  describe 'POST create' do
    it 'inserts a new product placement' do
      page = FactoryGirl.create(:page, website_id: @website.id)
      product = FactoryGirl.create(:product, website_id: @website.id)
      post 'api/admin/product_placements', product_placement: {page_id: page.id, product_id: product.id}
      expect(ProductPlacement.find_by(page_id: page.id, product_id: product.id)).to be
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all product placements in the website' do
      product_1 = FactoryGirl.create(:product, website_id: @website.id)
      product_2 = FactoryGirl.create(:product)
      page_1 = FactoryGirl.create(:page, website_id: @website.id)
      page_2 = FactoryGirl.create(:page)
      placement_1 = ProductPlacement.create!(page: page_1, product: product_1)
      placement_2 = ProductPlacement.create!(page: page_2, product: product_2)

      delete 'api/admin/product_placements'

      expect(ProductPlacement.find_by(id: placement_1.id)).not_to be
      expect(ProductPlacement.find_by(id: placement_2.id)).to be
    end

    it 'responds with 204 No Content' do
      delete 'api/admin/product_placements'

      expect(status).to eq 204
    end
  end
end
