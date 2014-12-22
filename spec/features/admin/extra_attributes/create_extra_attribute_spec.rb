require 'rails_helper'

feature 'Create extra attribute' do
  let!(:website) { FactoryGirl.create(:website) }

  background do
    sign_in_as_admin
  end

  scenario 'Navigate to new extra attribute' do
    given_i_am_on_the_extra_attributes_page
    when_i_click_on_new
    then_i_should_be_on_the_new_attribute_page
  end

  scenario 'Create new attribute' do
    given_i_am_on_the_new_attribute_page
    when_i_complete_the_form
    and_i_save
    then_a_new_attribute_is_created
  end

  def given_i_am_on_the_extra_attributes_page
    visit admin_extra_attributes_path
  end

  def given_i_am_on_the_new_attribute_page
    visit new_admin_extra_attribute_path
  end

  def when_i_click_on_new
    click_link 'New'
  end

  def when_i_complete_the_form
    fill_in 'Class name', with: 'Page'
    fill_in 'Attribute name', with: 'discount_rate'
  end

  def and_i_save
    click_button 'Save'
  end

  def then_i_should_be_on_the_new_attribute_page
    expect(current_path).to eq new_admin_extra_attribute_path
  end

  def then_a_new_attribute_is_created
    expect(ExtraAttribute.find_by(class_name: 'Page', attribute_name: 'discount_rate')).to be
  end
end
