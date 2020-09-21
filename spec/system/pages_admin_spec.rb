require "rails_helper"

RSpec.describe "Pages admin" do
  let(:website) { FactoryBot.create(:website) }

  before do
    Website.delete_all
    website
    sign_in_as_admin
  end

  let(:the_page) { FactoryBot.build(:page) }

  scenario "Create page", js: true do
    image = FactoryBot.create(:image)

    visit admin_pages_path
    click_link "New"
    fill_in "Name", with: the_page.name
    fill_in "Title", with: the_page.title
    fill_in "Description", with: the_page.description
    click_button "page_thumbnail_image_id_image_picker"
    click_button "image-#{image.id}"
    click_button "Create New Page"
    expect(page).to have_content "added new page"
    expect(Page.find_by(name: the_page.name, thumbnail_image_id: image.id)).to be
  end

  scenario "Edit page" do
    the_page.save!
    visit admin_pages_path
    click_link "Edit #{the_page}"
    new_name = SecureRandom.hex
    fill_in "Name", with: new_name
    click_button "Save"
    expect(Page.find_by(name: new_name)).to be
  end

  scenario "Delete page" do
    the_page.save
    visit admin_pages_path
    click_link "Delete #{the_page}"
    expect(Page.find_by(id: the_page.id)).to be_nil
  end

  scenario "Delete page from the edit screen" do
    the_page.save
    visit edit_admin_page_path(the_page)
    click_link "Delete #{the_page}"
    expect(Page.find_by(id: the_page.id)).to be_nil
  end
end
