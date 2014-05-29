require 'spec_helper'

describe '/admin/products/index.html.slim' do
  include ProductsHelper

  before(:each) do
    assigns[:products] = @products = [
      stub_model(Product),
      stub_model(Product)
    ]
    @products.stub!(:total_pages).and_return(0)
  end

  it "renders a list of products" do
    render
  end
end
