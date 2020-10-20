require "rails_helper"

RSpec.describe "Add order line" do
  let(:order) { FactoryBot.create(:order) }

  before do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario "Add order line happy path", js: true do
    visit edit_admin_order_path(order)

    click_button "Add Line"
    fill_in "order_line_quantity[-1]", with: "1"
    fill_in "order_line_product_sku[-1]", with: "P1"
    fill_in "order_line_product_name[-1]", with: "Product 1"
    fill_in "order_line_product_brand[-1]", with: "Brand 1"
    fill_in "order_line_product_weight[-1]", with: "1"
    fill_in "order_line_product_price[-1]", with: "1"
    fill_in "order_line_tax_percentage[-1]", with: "10"
    fill_in "order_line_feature_descriptions[-1]", with: "fd"

    click_button "Add Line"
    fill_in "order_line_quantity[-2]", with: "2"
    fill_in "order_line_product_sku[-2]", with: "P2"
    fill_in "order_line_product_name[-2]", with: "Product 2"
    fill_in "order_line_product_brand[-2]", with: "Brand 2"
    fill_in "order_line_product_weight[-2]", with: "2"
    fill_in "order_line_product_price[-2]", with: "2"
    fill_in "order_line_tax_percentage[-2]", with: "20"

    find(".cancel-save").click_button "Save"

    expect(page).to have_content "Edit Order"

    order.reload
    expect(order.order_lines.count).to eq 2
    ol = order.order_lines.first
    expect(ol.feature_descriptions).to eq "fd"
    expect(ol.product_brand).to eq "Brand 1"
  end
end
