require 'spec_helper'

feature 'Pages admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:the_page) { FactoryGirl.build(:page, website: website) }

  scenario 'Create page' do
    visit admin_pages_path
    click_link 'New'
    fill_in 'Name', with: the_page.name
    fill_in 'Title', with: the_page.title
    fill_in 'Description', with: the_page.description
    click_button 'Create New Page'
    expect(Page.find_by(name: the_page.name)).to be
  end

  scenario 'Edit page' do
    the_page.save!
    visit admin_pages_path
    click_link "Edit #{the_page}"
    new_name = SecureRandom.hex
    fill_in 'Name', with: new_name
    click_button 'Save'
    expect(Page.find_by(name: new_name)).to be
  end

  scenario 'Delete page' do
    the_page.save
    visit admin_pages_path
    click_link "Delete #{the_page}"
    expect(Page.find_by(id: the_page.id)).to be_nil
  end
end
