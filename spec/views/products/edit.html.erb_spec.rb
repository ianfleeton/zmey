require 'spec_helper'

describe "/products/edit.html.erb" do
  include ProductsHelper

  before(:each) do
    assigns[:product] = @product = stub_model(Product,
      :new_record? => false
    )
    assign(:w, stub_model(Website))
  end

  it "renders the edit product form" do
    render

    rendered.should have_selector("form", :method => "post", :action => product_path(@product)) do
    end
  end
end
