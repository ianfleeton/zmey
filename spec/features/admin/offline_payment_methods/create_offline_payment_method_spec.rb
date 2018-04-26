require 'rails_helper'

feature 'Create offline payment method' do
  background do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario 'Get to new offline payment method page' do
    visit admin_offline_payment_methods_path
    click_link 'New'
    expect(page).to have_content 'New Offline Payment Method'
  end

  scenario 'Create a new offline payment method' do
    visit new_admin_offline_payment_method_path
    fill_in 'Name', with: 'Cheque'
    click_button 'Save'
    expect(OfflinePaymentMethod.find_by(name: 'Cheque')).to be
  end
end
