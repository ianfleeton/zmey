require 'rails_helper'

RSpec.describe 'Product placements admin' do
  let(:website)  { FactoryBot.create(:website) }
  let(:page_obj) { FactoryBot.create(:page) }
  let(:product)  { FactoryBot.create(:product) }

  before do
    Website.delete_all
    website
    product
    sign_in_as_admin
  end

  scenario 'Place a product on a page' do
    visit edit_admin_page_path(page_obj)
    select product.name_with_sku, from: 'product_placement_product_id'
    click_button 'Add Product'

    expect(page_obj.products.first).to eq product
  end

  scenario 'Remove a product from a page' do
    ProductPlacement.create!(page: page_obj, product: product)

    visit edit_admin_page_path(page_obj)
    click_link 'Remove from page'

    expect(ProductPlacement.find_by(page: page_obj, product: product)).to be_nil
  end
end
