require 'rails_helper'

RSpec.describe 'Components admin' do
  let(:website) { FactoryBot.create(:website) }
  let(:product) { FactoryBot.create(:product) }
  let(:component) { FactoryBot.build(:component, product: product) }

  before do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'View components of a product' do
    component.save
    visit edit_admin_product_path(product)
    expect(page).to have_content component.name
  end

  scenario 'Add component to product' do
    visit edit_admin_product_path(product)
    click_link 'Add Component'
    fill_in 'Name', with: 'Size/Colour'
    click_button 'Create Component'
    expect(Component.find_by(product_id: product.id, name: 'Size/Colour')).to be
  end

  scenario 'Edit component' do
    component.save
    visit edit_admin_product_path(product)
    click_link "Edit #{component}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Component'
    expect(Component.find_by(name: new_name)).to be
  end
end
