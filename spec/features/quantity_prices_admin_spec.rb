require 'rails_helper'

feature 'Quantity prices administration' do
  let(:website) { FactoryGirl.create(:website) }
  let(:product) { FactoryGirl.create(:product, website: website) }
  let(:quantity_price) { FactoryGirl.build(:quantity_price, product: product) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'Add quantity price rule to product' do
    visit edit_admin_product_path(product)
    click_link 'Add Quantity/Price Rule'
    fill_in 'Quantity', with: '5'
    fill_in 'Price (GBP)', with: '10'
    click_button 'Create Quantity price'
    expect(QuantityPrice.find_by(product_id: product.id, quantity: 5, price: 10)).to be
  end

  scenario 'Edit quantity price rule' do
    quantity_price.save!
    visit edit_admin_product_path(product)
    click_link "Edit #{quantity_price}"
    fill_in 'Quantity', with: '500'
    click_button 'Update Quantity price'
    expect(QuantityPrice.find_by(product_id: product.id, quantity: 500)).to be
  end
end
