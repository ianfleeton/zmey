require 'spec_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin products API' do
  before do
    prepare_api_website
    Api::Admin::AdminController.any_instance.stub(:authenticated_api_key).and_return(@api_key)
  end

  describe 'POST create' do
    it 'inserts a new product into the website' do
      name = SecureRandom.hex
      sku = SecureRandom.hex
      weight = 1.234
      post 'api/admin/products', product: {name: name, sku: sku, weight: weight}
      expect(Product.find_by(sku: sku, weight: weight, website: @website)).to be
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
