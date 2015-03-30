require 'rails_helper'

feature 'Edit product admin' do
  background do
    FactoryGirl.create(:website)
    sign_in_as_admin
  end

  scenario 'Set nominal codes for Sage 50' do
    sales_nc = NominalCode.create!(code: 'sales1', description: 'sales 1')
    purchase_nc = NominalCode.create!(code: 'purchase1', description: 'purchase 1')
    product = FactoryGirl.create(:product)
    visit edit_admin_product_path(product)
    select sales_nc, from: 'Sales nominal code'
    select purchase_nc, from: 'Purchase nominal code'
    click_button 'Save'
    expect(product.reload.purchase_nominal_code).to eq purchase_nc
    expect(product.reload.sales_nominal_code).to eq sales_nc
  end

  scenario 'Remove image from product', js: true do
    product = FactoryGirl.create(:product, image: FactoryGirl.create(:image))
    visit edit_admin_product_path(product)
    click_button 'product_image_id_image_remove'
    click_button 'Save'
    expect(product.reload.image).to be_nil
  end
end
