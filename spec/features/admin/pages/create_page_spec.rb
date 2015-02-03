require 'rails_helper'

feature 'Create page' do
  let!(:website) { FactoryGirl.create(:website) }

  background do
    sign_in_as_admin
  end

  scenario 'Navigate to new page' do
    given_i_am_on_the_pages_page
    when_i_click_on_new
    then_i_should_be_on_the_new_page_page
  end

  scenario 'Create new page' do
    given_i_am_on_the_new_page_page
    when_i_complete_the_form
    and_i_save
    then_a_new_page_is_created
  end

  def given_i_am_on_the_pages_page
    visit admin_pages_path
  end

  def given_i_am_on_the_new_page_page
    visit new_admin_page_path
  end

  def when_i_click_on_new
    click_link 'New'
  end

  def when_i_complete_the_form
    fill_in 'Title', with: 'About Us'
    fill_in 'Name', with: 'About'
    fill_in 'page_slug', with: 'about'
    uncheck 'page_visible'
    fill_in 'Description', with: 'meta'
  end

  def and_i_save
    click_button 'Create New Page'
  end

  def then_i_should_be_on_the_new_page_page
    expect(current_path).to eq new_admin_page_path
  end

  def then_a_new_page_is_created
    expect(Page.find_by(title: 'About Us', description: 'meta', name: 'About', slug: 'about', visible: false)).to be
  end
end
