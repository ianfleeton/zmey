require "rails_helper"

RSpec.describe "Images admin" do
  before do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario "Upload a ZIP file of images" do
    visit new_admin_image_path
    attach_file "Image", "spec/fixtures/files/images/two-images.zip"
    fill_in "Name", with: "Widget"
    click_button "Upload New Image"
    expect(page).to have_content "2 images uploaded."
    expect(Image.find_by(name: "Widget 1")).to be
    expect(Image.find_by(name: "Widget 2")).to be
  end
end
