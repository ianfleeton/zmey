require 'spec_helper'

feature 'Orders admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:order) { FactoryGirl.build(:order, website: website) }

  scenario 'Delete order' do
    order.save!
    visit admin_orders_path
    click_link "Delete #{order}"
    expect(Order.find_by(order_number: order.order_number)).to be_nil
  end
end
