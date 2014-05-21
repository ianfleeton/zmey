require 'spec_helper'

feature 'Address book' do
  background do
    FactoryGirl.create(:website)
  end

  context 'signed in' do
    let(:user) { FactoryGirl.create(:user) }

    background do
      visit sign_in_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    context 'with addresses' do
      let(:work_address) { 'My Work Address' }
      let(:home_address) { 'My Home Address' }

      background do
        FactoryGirl.create(:address, user_id: user.id, label: work_address)
        FactoryGirl.create(:address, user_id: user.id, label: home_address)
      end

      scenario "Address book shows customer's addresses" do
        visit addresses_path
        expect(page).to have_content work_address
        expect(page).to have_content home_address
      end
    end
  end
end
