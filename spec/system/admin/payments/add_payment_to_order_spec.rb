require 'rails_helper'

RSpec.describe 'Create offline payment method' do
  before do
    FactoryBot.create(:website)
    FactoryBot.create(:offline_payment_method, name: 'Cheque')
    sign_in_as_admin
  end

  let(:amount) { 10.0 }
  let(:order) { FactoryBot.create(:order) }
  let!(:order_line) { FactoryBot.create(:order_line, order: order, product_price: 10) }

  scenario 'Add full payment to order' do
    add_payment(amount)
    expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
  end

  scenario 'Add partial payment to order' do
    add_payment(amount / 2)
    expect(order.reload.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
  end

  def add_payment(how_much)
    visit edit_admin_order_path(order)
    click_link 'Add Payment'
    select 'Cheque', from: 'payment_service_provider'
    fill_in 'Amount', with: how_much
    click_button 'Save'
  end
end
