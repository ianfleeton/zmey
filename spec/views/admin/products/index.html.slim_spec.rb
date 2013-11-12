require 'spec_helper'

describe '/admin/products/index.html.slim' do
  include ProductsHelper

  before(:each) do
    assigns[:products] = @products = [
      stub_model(Product),
      stub_model(Product)
    ]
  end

  it "renders a list of products" do
    render
  end
end
