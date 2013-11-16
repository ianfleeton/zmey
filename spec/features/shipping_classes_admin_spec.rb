require 'spec_helper'

feature 'Shipping classes admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:shipping_class) { FactoryGirl.build(:shipping_class, shipping_zone: FactoryGirl.create(:shipping_zone, website: website)) }

  scenario 'Create shipping class with existing zone' do
    zone = FactoryGirl.create(:shipping_zone, website: website)
    visit admin_shipping_classes_path
    click_link 'New'
    fill_in 'Name', with: shipping_class.name
    click_button 'Create Shipping class'
    expect(ShippingClass.find_by(name: shipping_class.name)).to be
  end

  scenario 'Edit shipping class' do
    shipping_class.save!
    visit admin_shipping_classes_path
    click_link "Edit #{shipping_class}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Update Shipping class'
    expect(ShippingClass.find_by(name: new_name)).to be
  end

  scenario 'Delete shipping class' do
    shipping_class.save!
    visit admin_shipping_classes_path
    click_link "Delete #{shipping_class}"
    expect(ShippingClass.find_by(id: shipping_class.id)).to be_nil
  end
end
