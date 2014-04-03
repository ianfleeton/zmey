require 'spec_helper'

feature 'Orders admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:order)      { FactoryGirl.create(:order, website_id: website.id) }
  let(:order_line) { FactoryGirl.create(:order_line, order_id: order.id) }

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
