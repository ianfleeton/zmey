require "rails_helper"

RSpec.describe "Discounts" do
  let!(:website) { FactoryBot.create(:website) }
  let(:product) { FactoryBot.create(:product) }

  before do
    Discount.create!(name: "Discount", coupon: "DISCOUNT", reward_type: "percentage_off_order")
  end

  scenario "Apply and remove discount" do
    visit product_path(product)
    click_button I18n.t("add_to_cart")
    fill_in "coupon_code", with: "DISCOUNT"
    click_button "Apply Coupon"
    expect(page).to have_content(I18n.t("controllers.basket.enter_coupon.applied"))
    click_link "Remove DISCOUNT"
    expect(page).to have_content(I18n.t("controllers.basket.remove_coupon.removed"))
  end

  scenario "Invalid coupons removed from session" do
    invalid = Discount.create!(name: "Invalid", coupon: "INVALID", reward_type: "percentage_off")
    visit product_path(product)
    click_button I18n.t("add_to_cart")
    fill_in "coupon_code", with: "INVALID"
    click_button "Apply Coupon"
    invalid.destroy
    visit basket_path
    expect(page).to have_content(I18n.t("controllers.basket.remove_invalid_discounts.removed"))
  end
end