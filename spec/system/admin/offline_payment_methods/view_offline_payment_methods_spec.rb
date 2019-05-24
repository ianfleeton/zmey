require 'rails_helper'

RSpec.describe 'View offline payment methods' do
  before do
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
