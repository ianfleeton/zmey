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

  def given_i_am_on_the_extra_attributes_page
    visit admin_extra_attributes_path
  end

  def when_i_click_on_edit
    click_link "Edit #{extra_attribute}"
  end

  def then_i_should_be_on_the_new_attribute_page
    expect(current_path).to eq edit_admin_extra_attribute_path(extra_attribute)
  end
end
