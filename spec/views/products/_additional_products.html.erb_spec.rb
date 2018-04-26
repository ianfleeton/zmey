require 'rails_helper'

describe 'products/_additional_products.html.erb' do
  let(:product) { FactoryBot.create(:product) }

  it 'renders' do
    render 'products/additional_products', product: product
  end

  context 'with additional products' do
    before do
      ad = AdditionalProduct.new(additional_product: product)
      allow(product).to receive(:additional_products).and_return([ad])
    end

    it 'renders' do
      render 'products/additional_products', product: product
    end
  end
end
