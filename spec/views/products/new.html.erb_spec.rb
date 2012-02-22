require 'spec_helper'

describe "/products/new.html.erb" do
  include ProductsHelper

  before(:each) do
    assign(:product, stub_model(Product, :new_record? => true))
    assign(:w, stub_model(Website))
  end

  it "renders new product form" do
    render

    rendered.should have_selector("form", :action => products_path, :method => "post") do
    end
  end
end
