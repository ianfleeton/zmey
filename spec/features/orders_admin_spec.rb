require 'spec_helper'

feature 'Orders admin' do
  fixtures :websites

  background do
    sign_in_as_admin
  end

  let(:order) { FactoryGirl.build(:order, website: websites(:guitar_gear)) }

  scenario 'Delete order' do
    order.save!
    visit admin_orders_path
    click_link "Delete #{order}"
    expect(Order.find_by(order_number: order.order_number)).to be_nil
  end
end
