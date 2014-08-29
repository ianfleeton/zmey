require 'rails_helper'

describe '/admin/products/index.html.slim' do
  include ProductsHelper

  before(:each) do
    assigns[:products] = @products = [
      FactoryGirl.create(:product),
      FactoryGirl.create(:product)
    ]
    allow(@products).to receive(:total_pages).and_return(0)
  end

  it "renders a list of products" do
    render
  end
end
