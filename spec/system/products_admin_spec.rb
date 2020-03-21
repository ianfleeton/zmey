require "rails_helper"

RSpec.describe "Products admin" do
  let(:website) { FactoryBot.create(:website) }

  before do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario "Create product" do
    product = FactoryBot.build(:product,
      age_group: "kids",
      allow_fractional_quantity: [true, false].sample,
      gender: "unisex",
      name: SecureRandom.hex,
      oversize: [true, false].sample,
      sku: SecureRandom.hex)
    visit admin_products_path
    click_link "New"

    select product.age_group, from: "Age group"
    select product.gender, from: "Gender"
    fill_in "Name", with: product.name
    fill_in "SKU", with: product.sku

    check_or_uncheck I18n.t("admin.products.form.allow_fractional_quantity"), product.allow_fractional_quantity?
    check_or_uncheck I18n.t("admin.products.form.oversize"), product.oversize?

    click_button "Save"

    expect(Product.find_by(
      age_group: product.age_group,
      allow_fractional_quantity: product.allow_fractional_quantity,
      gender: product.gender,
      name: product.name,
      oversize: product.oversize,
      sku: product.sku
    )).to be
  end
end
