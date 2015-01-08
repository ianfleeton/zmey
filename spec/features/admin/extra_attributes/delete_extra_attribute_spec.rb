require 'rails_helper'

feature 'Delete extra attribute' do
  let!(:website) { FactoryGirl.create(:website) }
  let!(:extra_attribute) { FactoryGirl.create(:extra_attribute) }

  background do
    sign_in_as_admin
  end

  scenario 'Delete extra attribute' do
    given_i_am_on_the_extra_attributes_page
    when_i_click_on_delete
    then_the_attribute_is_deleted
  end

  def given_i_am_on_the_extra_attributes_page
    visit admin_extra_attributes_path
  end

  def when_i_click_on_delete
    click_link "Delete #{extra_attribute}"
  end

  def then_the_attribute_is_deleted
    expect(ExtraAttribute.find_by(id: extra_attribute.id)).to be_nil
  end
end
