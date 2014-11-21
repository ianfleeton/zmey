require 'rails_helper'

describe BasketItem do
  describe '#line_total(inc_tax)' do
    context 'when inc_tax is true' do
      it 'returns the quantity times the price of the product including tax when buying that quantity' do
        product = FactoryGirl.build(:product)
        allow(product).to receive(:price_inc_tax).with(2).and_return(12)
        item = BasketItem.new(quantity: 2)
        item.product = product
        expect(item.line_total(true)).to eq 24
      end
    end

    context 'when inc_tax is false' do
      it 'returns the quantity times the price of the product excluding tax when buying that quantity' do
        product = FactoryGirl.build(:product)
        allow(product).to receive(:price_ex_tax).with(2).and_return(10)
        item = BasketItem.new(quantity: 2)
        item.product = product
        expect(item.line_total(false)).to eq 20
      end
    end
  end

  describe '#adjust_quantity' do
    let(:basket_item) { FactoryGirl.build(:basket_item, product_id: product.id) }

    before do
      basket_item.quantity = 1.6
      basket_item.save
    end

    context 'when product allows fractional quantity' do
      let(:product) { FactoryGirl.create(:product, allow_fractional_quantity: true) }

      it 'leaves the quantity as a decimal' do
        expect(basket_item.reload.quantity).to eq 1.6
      end
    end

    context 'when product disallows fractional quantity' do
      let(:product) { FactoryGirl.create(:product, allow_fractional_quantity: false) }

      it 'rounds the quantity up' do
        expect(basket_item.reload.quantity).to eq 2
      end
    end
  end

  describe '#weight' do
    it 'returns the weight of the product times the quantity' do
      product = FactoryGirl.build(:product, weight: 2.5)
      item = BasketItem.new(quantity: 3)
      item.product = product
      expect(item.weight).to eq 7.5
    end
  end
end
