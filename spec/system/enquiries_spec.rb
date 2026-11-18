require "rails_helper"

RSpec.describe "Enquiries", type: :system do
  before { FactoryBot.create(:website) }

  def fill_in_enquiry
    visit new_enquiry_path
    fill_in "Name", with: "Ernie"
    fill_in "Telephone", with: "01234 567890"
    fill_in "Email", with: "ernie@example.org"
    fill_in "Your enquiry", with: "Do you sell widgets?"
  end

  scenario "Customer sends an enquiry" do
    fill_in_enquiry
    expect { click_button "Send Enquiry" }.to change(Enquiry, :count).by(1)
    expect(page).to have_current_path(thank_you_enquiries_path)
  end

  scenario "Bot fills in the honeypot field" do
    fill_in_enquiry
    fill_in "Leave this field empty", with: "spam"
    expect { click_button "Send Enquiry" }.not_to change(Enquiry, :count)
    expect(page).to have_current_path(thank_you_enquiries_path)
  end
end
