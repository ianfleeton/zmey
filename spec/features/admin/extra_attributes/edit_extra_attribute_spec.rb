require 'rails_helper'

feature 'Edit extra attribute' do
  let!(:website) { FactoryGirl.create(:website) }
  let!(:extra_attribute) { FactoryGirl.create(:extra_attribute) }

  background do
    sign_in_as_admin
  end

  scenario 'Navigate to edit extra attribute' do
    given_i_am_on_the_extra_attributes_page
    when_i_click_on_edit
    then_i_should_be_on_the_new_attribute_page
  end

  scenario 'Edit extra attribute' do
    given_i_am_on_the_edit_extra_attribute_page
    when_i_edit_the_form
    and_i_save
    then_a_the_attribute_is_updated
  end

  def given_i_am_on_the_extra_attributes_page
    visit admin_extra_attributes_path
  end

  def given_i_am_on_the_edit_extra_attribute_page
    visit edit_admin_extra_attribute_path(extra_attribute)
  end

  def when_i_click_on_edit
    click_link "Edit #{extra_attribute}"
  end

  def when_i_edit_the_form
    @new_attribute_name = SecureRandom.hex
    @new_class_name = SecureRandom.hex
    fill_in 'Attribute name', with: @new_attribute_name
    fill_in 'Class name', with: @new_class_name
  end

  def and_i_save
    click_button 'Save'
  end

  def then_i_should_be_on_the_new_attribute_page
    expect(current_path).to eq edit_admin_extra_attribute_path(extra_attribute)
  end
end
