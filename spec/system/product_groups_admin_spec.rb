require "rails_helper"

RSpec.describe "Product groups admin" do
  let(:website) { FactoryBot.create(:website) }

  before do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario "Create product group" do
    location = FactoryBot.create(:location, name: "Books")
    visit admin_product_groups_path
    click_link "New"

    fill_in "Name", with: "Fiction"
    select "Books", from: "Location"

    click_button "Create Product group"

    expect(ProductGroup.find_by(
      location_id: location.id,
      name: "Fiction"
    )).to be
  end

  scenario "Edit product group" do
    product_group = FactoryBot.create(:product_group)
    new_name = SecureRandom.hex

    visit admin_product_groups_path
    click_link "Edit #{product_group}"
    fill_in "Name", with: new_name
    click_button "Update Product group"

    expect(ProductGroup.find_by(name: new_name)).to be
  end

  scenario "Delete product group" do
    product_group = FactoryBot.create(:product_group)
    visit admin_product_groups_path
    click_link "Delete #{product_group}"
    expect(ProductGroup.find_by(id: product_group.id)).to be_nil
  end
end
