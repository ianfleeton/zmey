require 'spec_helper'

feature 'Features administration' do
  let(:website) { FactoryGirl.create(:website) }
  let(:product) { FactoryGirl.create(:product, website: website) }
  let(:feature) { FactoryGirl.build(:feature, product: product) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'View features of a product' do
    feature.save
    visit edit_admin_product_path(product)
    expect(page).to have_content feature.name
  end

  scenario 'Add feature to product' do
    visit edit_admin_product_path(product)
    click_link 'Add Feature'
    fill_in 'Name', with: 'Size'
    click_button 'Create Feature'
    expect(Feature.find_by(product_id: product.id, name: 'Size')).to be
  end

  scenario 'Edit feature' do
    feature.save
    visit edit_admin_product_path(product)
    click_link "Edit #{feature}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Feature'
    expect(Feature.find_by(name: new_name)).to be
  end
end
