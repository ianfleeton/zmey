require 'rails_helper'

RSpec.describe '/admin/products/edit.html.slim', type: :view do
  include ProductsHelper

  let(:product) { FactoryBot.create(:product) }

  before(:each) do
    assign(:product, product)
    assign(:product_group_placement, ProductGroupPlacement.new)
    allow(view).to receive(:website).and_return(FactoryBot.build(:website))
  end

  it "renders the edit product form" do
    render

    expect(rendered).to have_selector("form[action='#{admin_product_path(product)}'][method='post']")
  end
end
