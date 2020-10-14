# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Remove order line", type: :system do
  let(:order) { FactoryBot.create(:order) }

  before { sign_in_as_admin }

  scenario "Remove order line happy path", js: true do
    ol = FactoryBot.create(:order_line, order_id: order.id, product_name: "Widget", product_price: 10, quantity: 1)

    visit edit_admin_order_path(order)

    click_link "Delete #{ol}"

    a = page.driver.browser.switch_to.alert
    a.accept

    expect(page).to have_content "Order line removed."

    order.reload
    expect(order.order_lines.count).to eq 0
    expect(order.total).to eq 0
  end
end
