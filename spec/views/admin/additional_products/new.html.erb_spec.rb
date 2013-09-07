require 'spec_helper'

describe 'admin/additional_products/new.html.erb' do
  let(:abacus) { Product.new }
  let(:additional_product) { AdditionalProduct.new(product: abacus) }
  let(:website) { mock_model(Website, products: [abacus]) }

  before do
    assign(:additional_product, additional_product)
    assign(:w, website)
  end

  it 'renders' do
    render
  end
end
