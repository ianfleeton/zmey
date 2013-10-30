require 'spec_helper'

feature 'Websites admin' do
  background do
    FactoryGirl.create(:website)
    sign_in_as_admin
  end

  let(:website) { FactoryGirl.build(:website) }

  scenario 'Create website' do
    visit admin_websites_path
    click_link 'New Website'
    name = SecureRandom.hex
    fill_in 'Name', with: name
    fill_in 'Address line 1', with: '123 Street'
    fill_in 'Address line 2', with: 'Balby'
    fill_in 'Town city', with: 'Doncaster'
    fill_in 'County', with: 'South Yorkshire'
    fill_in 'Postcode', with: 'DN4 9ZZ'
    click_button 'Create New Website'
    expect(Website.find_by(name: name)).to be_nil
  end
end
