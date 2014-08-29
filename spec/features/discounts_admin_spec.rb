require 'rails_helper'

feature 'Discounts admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:discount) { FactoryGirl.build(:discount, website: website) }

  scenario 'Create discount' do
    visit admin_discounts_path
    click_link 'New'
    fill_in 'Name', with: discount.name
    click_button 'Create Discount'
    expect(Discount.find_by(name: discount.name)).to be
  end

  scenario 'Edit discount' do
    discount.save!
    visit admin_discounts_path
    click_link "Edit #{discount}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    select 'Percentage off', from: 'Reward type'
    fill_in 'Reward amount', with: 10
    fill_in 'Threshold', with: 5
    uncheck 'Exclude reduced products'
    click_button 'Update Discount'
    expect(Discount.find_by(name: new_name, reward_type: 'percentage_off', reward_amount: 10, threshold: 5, exclude_reduced_products: false)).to be
  end

  scenario 'Delete discount' do
    discount.save!
    visit admin_discounts_path
    click_link "Delete #{discount}"
    expect(Discount.find_by(name: discount.name)).to be_nil
  end
end
