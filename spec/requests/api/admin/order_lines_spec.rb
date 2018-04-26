require 'rails_helper'

describe 'Admin order lines API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    let(:order) { FactoryBot.create(:order) }
    let(:product) { FactoryBot.create(:product, price: 12.0, rrp: 13.0, weight: 1.23, tax_type: Product::INC_VAT) }

    let(:order_id)    { order.id }
    let(:product_id)  { nil }
    let(:quantity)    { 1 }

    # Optional attributes
    let(:product_name)   { nil }
    let(:product_price)  { nil }
    let(:product_rrp)    { nil }
    let(:product_weight) { nil }
    let(:tax_amount)     { nil }

    before do
      post '/api/admin/order_lines', params: {
        order_line: {
          order_id: order_id,
          product_id: product_id,
          product_name: product_name,
          product_price: product_price,
          product_rrp: product_rrp,
          product_weight: product_weight,
          quantity: quantity,
          tax_amount: tax_amount
        }
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

      it 'sets the product name' do
        expect(order_line.product_name).to eq product.name
      end

      it 'sets the product price' do
        expect(order_line.product_price).to eq product.price_ex_tax(quantity)
      end

      it 'sets the product RRP' do
        expect(order_line.product_rrp).to eq product.rrp
      end

      it 'sets the product SKU' do
        expect(order_line.product_sku).to eq product.sku
      end

      it 'sets the product weight' do
        expect(order_line.product_weight).to eq product.weight
      end

      it 'sets the tax amount' do
        expect(order_line.tax_amount).to eq product.tax_amount(quantity) * quantity
      end

      context 'with optional attributes supplied' do
        let(:product_name)   { 'Jeans' }
        let(:product_price)  { 56.78 }
        let(:product_rrp)    { 67.89 }
        let(:product_weight) { 0.4 }
        let(:tax_amount)     { 8.52 }

        it 'uses them instead' do
          expect(order_line.product_name).to eq product_name
          expect(order_line.product_price).to eq product_price
          expect(order_line.product_rrp).to eq product_rrp
          expect(order_line.product_weight).to eq product_weight
          expect(order_line.tax_amount).to eq tax_amount
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:order_line) { FactoryBot.create(:order_line) }

    before { delete '/api/admin/order_lines/' + id.to_s }

    context 'when order line exists' do
      let(:id) { order_line.id }

      it 'returns 204' do
        expect(response.status).to eq 204
      end

      it 'deletes the order line' do
        expect(OrderLine.find_by(id: order_line.id)).to be_nil
      end
    end

    context 'when order line does not exist' do
      let(:id) { order_line.id + 1 }

      it 'returns 404' do
        expect(response.status).to eq 404
      end
    end
  end
end
