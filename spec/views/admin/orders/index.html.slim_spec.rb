require "rails_helper"

RSpec.describe "admin/orders/index", type: :view do
  context "with orders" do
    let!(:order) { FactoryBot.create(:order, billing_full_name: "BILLING FN") }

    before do
      assign(:orders, Order.paginate({page: 1}))
    end

    it "displays the billing full name" do
      render
      expect(rendered).to have_content "BILLING FN"
    end
  end
end
