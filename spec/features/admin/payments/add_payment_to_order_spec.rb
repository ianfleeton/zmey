require 'rails_helper'

feature 'Create offline payment method' do
  background do
    FactoryGirl.create(:website)
    FactoryGirl.create(:offline_payment_method, name: 'Cheque')
    sign_in_as_admin
  end

  let(:amount) { 10.0 }
  let(:order) { FactoryGirl.create(:order) }
  let!(:order_line) { FactoryGirl.create(:order_line, order: order) }

  scenario 'Add full payment to order' do
    visit edit_admin_order_path(order)
    click_link 'Add Payment'
    select 'Cheque', from: 'payment_service_provider'
    fill_in 'Amount', with: amount
    click_button 'Save'
    expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
  end
end
