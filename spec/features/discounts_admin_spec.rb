require 'spec_helper'

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
    click_button 'Update Discount'
    expect(Discount.find_by(name: new_name)).to be
  end

  scenario 'Delete discount' do
    discount.save!
    visit admin_discounts_path
    click_link "Delete #{discount}"
    expect(Discount.find_by(name: discount.name)).to be_nil
  end
end
