require "rails_helper"

RSpec.describe "Edit shipping details" do
  let(:order) { FactoryBot.create(:order) }

  before do
    FactoryBot.create(:website)
    sign_in_as_admin
  end

  scenario "Edit shipping method and amount" do
    visit edit_admin_order_path(order)
    fill_in "Shipping method", with: "Long distance courier"
    fill_in "Shipping amount", with: "8"
    fill_in "Shipping VAT amount", with: "1.6"
    click_save
    order.reload
    expect(order.shipping_method).to eq "Long distance courier"
    expect(order.shipping_amount).to eq 8
    expect(order.shipping_vat_amount).to eq BigDecimal("1.6")
    expect(order.total).to eq BigDecimal("9.6")
  end

  scenario "Edit delivery instructions" do
    visit edit_admin_order_path(order)
    fill_in "Delivery instructions", with: "Leave in shed"
    click_save
    order.reload
    expect(order.delivery_instructions).to eq "Leave in shed"
  end

  def click_save
    find(".cancel-save").click_button "Save"
  end
end
