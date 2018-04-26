require 'rails_helper'

feature 'Countries admin' do
  let(:website) { FactoryBot.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:country) { FactoryBot.build(:country) }

  scenario 'Create country' do
    visit admin_countries_path
    click_link 'New'
    fill_in 'Name', with: country.name
    fill_in 'ISO 3166-1 alpha-2', with: country.iso_3166_1_alpha_2
    click_button 'Create Country'
    expect(Country.find_by(name: country.name)).to be
  end

  scenario 'Edit country' do
    country.save
    visit admin_countries_path
    click_link "Edit #{country}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Country'
    expect(Country.find_by(name: new_name)).to be
  end

  scenario 'Delete country' do
    country.save
    visit admin_countries_path
    click_link "Delete #{country}"
    expect(Country.find_by(id: country.id)).to be_nil
  end
end
