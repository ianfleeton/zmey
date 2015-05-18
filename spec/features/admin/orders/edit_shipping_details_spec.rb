require 'rails_helper'

feature 'Edit shipping details' do
  let(:order) { FactoryGirl.create(:order) }

  background do
    FactoryGirl.create(:website)
    sign_in_as_admin
  end

  scenario 'Edit shipping method and amount' do
    visit edit_admin_order_path(order)
    fill_in 'Shipping method', with: 'Long distance courier'
    fill_in 'Shipping amount', with: '8'
    fill_in 'Shipping tax amount', with: '1.6'
    click_button 'Save'
    order.reload
    expect(order.shipping_method).to eq 'Long distance courier'
    expect(order.shipping_amount).to eq 8
    expect(order.shipping_tax_amount).to eq 1.6
    expect(order.total).to eq 9.6
  end
end
