require 'spec_helper'

describe '/admin/products/new.html.slim' do
  include ProductsHelper

  before(:each) do
    assign(:product, Product.new)
    assign(:w, stub_model(Website))
  end

  it 'renders new product form' do
    render

    rendered.should have_selector("form[action='#{admin_products_path}'][method='post']")
  end

  it 'has a field for gender' do
    render

    expect(rendered).to have_selector('input[id="product_gender"]')
  end
end
