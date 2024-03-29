require "rails_helper"

describe "admin/products/new" do
  include ProductsHelper

  before(:each) do
    assign(:product, Product.new)
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(FactoryBot.build(:website))
    end
  end

  it "renders new product form" do
    render

    expect(rendered).to have_selector("form[action='#{admin_products_path}'][method='post']")
  end

  it "has a field for age group" do
    render
    expect(rendered).to have_selector('select[id="product_age_group"]')
  end

  it "has a field for gender" do
    render
    expect(rendered).to have_selector('select[id="product_gender"]')
  end
end
