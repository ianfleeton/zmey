require 'rails_helper'

feature 'Orders admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:order)      { FactoryGirl.create(:order, website_id: website.id) }
  let(:order_line) { FactoryGirl.create(:order_line, order_id: order.id) }

  scenario 'Create order' do
    FactoryGirl.create(:country, website_id: website.id)

    visit admin_orders_path
    click_link 'New'
    email = "#{SecureRandom.hex}@example.org"
    fill_in 'Email address', with: email
    fill_in 'Billing address line 1', with: '123 Street'
    fill_in 'Billing town city', with: 'Doncaster'
    fill_in 'Billing postcode', with: 'DN99 1AB'
    select website.countries.first, from: 'Billing country'
    fill_in 'Delivery address line 1', with: '123 Street'
    fill_in 'Delivery town city', with: 'Doncaster'
    fill_in 'Delivery postcode', with: 'DN99 1AB'
    select website.countries.first, from: 'Delivery country'
    click_button 'Save'

    expect(Order.find_by(email_address: email)).to be
  end

  scenario 'Delete order' do
    order
    visit admin_orders_path
    click_link "Delete #{order}"
    expect(Order.find_by(order_number: order.order_number)).to be_nil
  end

  scenario 'Update order line' do
    order_line
    visit admin_order_path(order)
    fill_in 'order_line_shipped', with: '1'
    click_button 'Update'
    expect(order_line.reload.shipped).to eq 1
  end
end
