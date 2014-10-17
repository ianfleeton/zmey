require 'rails_helper'

describe '/admin/products/edit.html.slim' do
  include ProductsHelper

  before(:each) do
    assigns[:product] = @product = FactoryGirl.create(:product)
    allow(view).to receive(:website).and_return(FactoryGirl.build(:website))
  end

  it "renders the edit product form" do
    render

    expect(rendered).to have_selector("form[action='#{admin_product_path(@product)}'][method='post']")
  end
end
