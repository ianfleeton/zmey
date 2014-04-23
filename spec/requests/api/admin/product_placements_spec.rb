require 'spec_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin product placements API' do
  before do
    prepare_api_website
    Api::Admin::AdminController.any_instance.stub(:authenticated_api_key).and_return(@api_key)
  end

  describe 'POST create' do
    it 'inserts a new product placement' do
      page = FactoryGirl.create(:page, website_id: @website.id)
      product = FactoryGirl.create(:product, website_id: @website.id)
      post 'api/admin/product_placements', product_placement: {page_id: page.id, product_id: product.id}
      expect(ProductPlacement.find_by(page_id: page.id, product_id: product.id)).to be
    end
  end
end
