require 'rails_helper'

feature 'Use extra attribute' do
  let!(:website) { FactoryGirl.create(:website) }
  let(:page_subject) { FactoryGirl.create(:page, website: website) }

  background do
    sign_in_as_admin
    ExtraAttribute.create!(attribute_name: 'subheading', class_name: 'Page')
  end

  scenario 'Change an extra attribute belonging to a page' do
    given_i_am_on_the_page_editing_page
    when_i_change_the_subheading
    and_i_save
    then_the_subheading_is_updated
  end

  def given_i_am_on_the_page_editing_page
    visit edit_admin_page_path(page_subject)
  end

  def when_i_change_the_subheading
    @new_subheading = SecureRandom.hex
    fill_in 'Subheading', with: @new_subheading
  end

  def and_i_save
    click_button 'Save'
  end

  def then_the_subheading_is_updated
    page_subject.reload
    expect(page_subject.extra_json['subheading']).to eq @new_subheading
  end
end
