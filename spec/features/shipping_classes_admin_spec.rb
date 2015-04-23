require 'rails_helper'

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
    if charge_tax = [true, false].sample
      check 'Charge tax'
    else
      uncheck 'Charge tax'
    end
    if invalid_over_highest_trigger = [true, false].sample
      check 'Invalid over highest trigger'
    else
      uncheck 'Invalid over highest trigger'
    end
    click_button 'Create Shipping class'
    expect(ShippingClass.find_by(
      name: shipping_class.name,
      charge_tax: charge_tax,
      invalid_over_highest_trigger: invalid_over_highest_trigger
    )).to be
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

  scenario 'Add shipping table row to class' do
    shipping_class.save!
    visit edit_admin_shipping_class_path(shipping_class)
    click_link 'New'
    fill_in 'Trigger value', with: '10.5'
    fill_in 'Amount', with: '5.99'
    click_button 'Save'
    expect(ShippingTableRow.find_by(trigger_value: 10.5, amount: 5.99, shipping_class_id: shipping_class.id)).to be
  end

  scenario 'Delete shipping table row' do
    shipping_class.save!
    str = ShippingTableRow.create!(trigger_value: 10.5, amount: 5.99, shipping_class_id: shipping_class.id)
    visit edit_admin_shipping_class_path(shipping_class)
    click_link "Delete #{str}"
    expect(ShippingTableRow.find_by(id: str.id)).to be_nil
  end
end
