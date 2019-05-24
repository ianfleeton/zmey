require 'rails_helper'

RSpec.describe 'Choices admin' do
  let(:website) { FactoryBot.create(:website) }
  let(:product) { FactoryBot.create(:product) }
  let(:feature) { FactoryBot.create(:feature, product: product) }
  let(:choice) { FactoryBot.create(:choice, feature: feature) }

  before do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'View choices of a feature' do
    choice.save
    visit edit_admin_feature_path(feature)
    expect(page).to have_content choice.name
  end

  scenario 'Add choice to feature' do
    visit edit_admin_feature_path(feature)
    click_link 'Add Choice'
    fill_in 'Name', with: 'Blue'
    click_button 'Create Choice'
    expect(Choice.find_by(feature_id: feature.id, name: 'Blue')).to be
  end

  scenario 'Edit choice' do
    choice.save
    visit edit_admin_feature_path(feature)
    click_link "Edit #{choice}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Choice'
    expect(Choice.find_by(name: new_name)).to be
  end
end
