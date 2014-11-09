require 'rails_helper'

describe 'Admin order lines API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    let(:order) { FactoryGirl.create(:order, website_id: @website.id) }
    let(:product) { FactoryGirl.create(:product, website_id: @website.id, price: 12.0, tax_type: Product::INC_VAT) }

    let(:order_id)   { order.id }
    let(:product_id) { nil }
    let(:quantity)   { 1 }

    before do
      post '/api/admin/order_lines', order_line: {
        order_id: order_id,
        product_id: product_id,
        quantity: quantity
      }
    end

    context 'with valid order_id, product_id and quantity' do
      let(:product_id) { product.id }
      let(:order_line) { order.reload.order_lines.first }

      it 'creates an order line' do
        expect(order_line).to be
      end

      it 'associates the product with the order line' do
        expect(order_line.product).to eq product
      end

      it 'sets the product price' do
        expect(order_line.product_price).to eq product.price_ex_tax(quantity)
      end

      it 'sets the product SKU' do
        expect(order_line.product_sku).to eq product.sku
      end

      it 'sets the tax amount' do
        expect(order_line.tax_amount).to eq product.tax_amount(quantity) * quantity
      end
    end
  end
end
