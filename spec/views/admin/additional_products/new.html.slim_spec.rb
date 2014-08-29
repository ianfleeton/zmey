require 'rails_helper'

describe 'admin/additional_products/new.html.slim' do
  let(:abacus) { Product.new }
  let(:additional_product) { AdditionalProduct.new(product: abacus) }
  let(:website) { double(Website, products: [abacus]) }

  before do
    assign(:additional_product, additional_product)
    assign(:w, website)
  end

  it 'renders' do
    render
  end
end
