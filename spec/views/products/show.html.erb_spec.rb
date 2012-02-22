require 'spec_helper'

describe "/products/show.html.erb" do
  include ProductsHelper
  before(:each) do
    assigns[:product] = @product = stub_model(Product)
    assign(:w, stub_model(Website))
    view.stub(:admin_or_manager?).and_return(:false)
  end

  it "renders attributes in <p>" do
    render
  end
end
