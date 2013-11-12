require 'spec_helper'

describe '/admin/products/edit.html.slim' do
  include ProductsHelper

  before(:each) do
    assigns[:product] = @product = stub_model(Product,
      :new_record? => false
    )
    assign(:w, stub_model(Website))
  end

  it "renders the edit product form" do
    render

    rendered.should have_selector("form[action='#{admin_product_path(@product)}'][method='post']")
  end
end
