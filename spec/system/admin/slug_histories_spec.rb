require "rails_helper"

RSpec.describe "Slug histories admin", type: :system do
  before { sign_in_as_admin }

  scenario "Add a new slug history" do
    terms = FactoryBot.create(:page, name: "Terms")
    visit admin_slug_histories_path

    fill_in "Slug", with: "terms"
    select "Terms", from: "Page"

    click_button "Create Slug history"

    expect(page).to have_content "Added."

    expect(page).to have_css "td", text: "http:///terms"

    sh = SlugHistory.last
    expect(sh.page).to eq terms
    expect(sh.slug).to eq "terms"
  end
end
