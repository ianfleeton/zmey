require 'rails_helper'

feature 'View offline payment methods' do
  background do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario 'Visit offline payments page from admin' do
    click_link 'Offline Payments'
  end

  scenario 'View list of offline payment methods' do
    payment_method = FactoryBot.create(:offline_payment_method)
    visit admin_offline_payment_methods_path
    expect(page).to have_content payment_method.name
  end
end
