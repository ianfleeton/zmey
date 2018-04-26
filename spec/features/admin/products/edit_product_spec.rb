require 'rails_helper'

feature 'Edit product admin' do
  background do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario 'Remove image from product', js: true do
    product = FactoryBot.create(:product, image: FactoryBot.create(:image))
    visit edit_admin_product_path(product)
    click_button 'product_image_id_image_remove'
    click_button 'Save'
    expect(product.reload.image).to be_nil
  end
end
