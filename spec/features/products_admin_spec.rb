require 'spec_helper'

feature 'Products admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'Create product' do
    product = FactoryGirl.build(:product,
      gender: 'unisex',
      name:   SecureRandom.hex,
      sku:    SecureRandom.hex
    )
    visit admin_products_path
    click_link 'New'

    select product.gender, from: 'Gender'
    fill_in 'Name',   with: product.name
    fill_in 'SKU',    with: product.sku

    click_button 'Create Product'

    expect(Product.find_by(
      gender: product.gender,
      name:   product.name,
      sku:    product.sku
    )).to be
  end
end