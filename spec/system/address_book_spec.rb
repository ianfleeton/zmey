require 'rails_helper'

RSpec.describe 'Address book', type: :system do
  let(:country) { FactoryBot.create(:country) }
  let(:website) { FactoryBot.create(:website, country: country) }

  before do
    Website.delete_all
    website
  end

  context 'signed in' do
    let(:user) { FactoryBot.create(:user) }

    before do
      visit sign_in_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign In'
    end

    context 'without addresses' do
      scenario 'Add a new address' do
        visit addresses_path
        click_link I18n.t('addresses.index.add_new_address')
        fill_in 'Full name',      with: 'A. Shopper'
        fill_in 'Email',          with: 'shopper@example.org'
        fill_in 'Address line 1', with: '123 Street'
        fill_in 'Town/city',      with: 'London'
        fill_in 'Postcode',       with: 'L0N D0N'
        click_button 'Save'
        expect(Address.find_by(full_name: 'A. Shopper')).to be
        # Should return to address book
        expect(page).to have_content I18n.t('addresses.index.heading')
      end
    end

    context 'with addresses' do
      let(:work_address) { 'My Work Address' }
      let(:home_address) { 'My Home Address' }

      let!(:work_address) { FactoryBot.create(:address, user_id: user.id, label: 'Work') }
      let!(:home_address) { FactoryBot.create(:address, user_id: user.id, label: 'Home') }

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
