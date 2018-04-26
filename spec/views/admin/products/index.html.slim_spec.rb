require 'rails_helper'

RSpec.describe 'admin/products/index.html.slim', type: :view do
  include ProductsHelper

  before(:each) do
    @products = [
      FactoryBot.create(:product),
      FactoryBot.create(:product)
    ]
    allow(@products).to receive(:total_pages).and_return(0)
  end

  it "renders a list of products" do
    render
  end

  it 'links to export product CSV' do
    render
    expect(rendered).to have_selector "a[href='#{csv_admin_export_index_path(class_name: 'Product')}']"
  end
end
