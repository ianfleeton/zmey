require "rails_helper"

RSpec.describe "View order comments" do
  let(:order) { FactoryBot.create(:order) }

  before do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario "View order comments when editing order" do
    OrderComment.create(order: order, comment: "Refund requested")
    visit edit_admin_order_path(order)
    expect(page).to have_content "Refund requested"
  end
end
