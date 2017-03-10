require 'rails_helper'

feature 'Edit product admin' do
  background do
    FactoryGirl.create(:website)
    sign_in_as_admin
  end

  scenario 'Remove image from product', js: true do
    product = FactoryGirl.create(:product, image: FactoryGirl.create(:image))
    visit edit_admin_product_path(product)
    hide_navbar
    click_button 'product_image_id_image_remove'
    click_button 'Save'
    expect(product.reload.image).to be_nil
  end
end
