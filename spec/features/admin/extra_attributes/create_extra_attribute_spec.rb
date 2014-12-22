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

  def given_i_am_on_the_extra_attributes_page
    visit admin_extra_attributes_path
  end

  def when_i_click_on_new
    click_link 'New'
  end

  def then_i_should_be_on_the_new_attribute_page
    expect(current_path).to eq new_admin_extra_attribute_path
  end
end
