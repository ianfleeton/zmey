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

      let!(:work_address) { FactoryGirl.create(:address, user_id: user.id, label: 'Work') }
      let!(:home_address) { FactoryGirl.create(:address, user_id: user.id, label: 'Home') }

      scenario "Address book shows customer's addresses" do
        visit addresses_path
        expect(page).to have_content work_address.label
        expect(page).to have_content home_address.label
      end

      scenario "Update an address" do
        visit addresses_path
        click_link "Edit #{work_address}"
        new_label = SecureRandom.hex
        fill_in 'Label', with: new_label
        click_button 'Save'
        work_address.reload
        expect(work_address.label).to eq new_label
      end
    end
  end
end
