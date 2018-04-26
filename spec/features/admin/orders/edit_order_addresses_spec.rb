require 'rails_helper'

feature 'Edit order addresses' do
  let(:order) { FactoryBot.create(:order) }

  background do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  let(:new_address_line_1) { 'New address line 1' }
  let(:new_address_line_2) { 'New address line 2' }
  let(:new_town_city) { 'New town' }
  let(:new_county) { 'New county' }
  let(:new_postcode) { 'NEW POST' }

  scenario 'Edit billing address' do
    edit_address(:billing)
  end

  scenario 'Edit delivery address' do
    edit_address(:delivery)
  end

  def edit_address(type)
    visit edit_admin_order_path(order)
    fill_in "order_#{type}_address_line_1", with: new_address_line_1
    fill_in "order_#{type}_address_line_2", with: new_address_line_2
    fill_in "order_#{type}_town_city", with: new_town_city
    fill_in "order_#{type}_county", with: new_county
    fill_in "order_#{type}_postcode", with: new_postcode
    click_button 'Save'
    expect(Order.find_by(
      "#{type}_address_line_1" => new_address_line_1,
      "#{type}_address_line_2" => new_address_line_2,
      "#{type}_town_city" => new_town_city,
      "#{type}_county" => new_county,
      "#{type}_postcode" => new_postcode
    )).to be
  end
end
