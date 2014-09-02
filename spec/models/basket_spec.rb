require 'rails_helper'

describe Basket do
  describe '#set_product_quantities' do
    let!(:basket) { FactoryGirl.create(:basket) }
    let(:product) { FactoryGirl.create(:product) }

    it 'updates existing quantities' do
      basket.basket_items << BasketItem.new(product: product, quantity: 1)
      basket.set_product_quantities(product.id => 3)
      expect(basket.basket_items.first.quantity).to eq 3
    end

    it 'adds new products' do
      basket.set_product_quantities(product.id => 2)
      expect(basket.basket_items.first.quantity).to eq 2
    end

    it 'removes products with quantity < 1' do
      basket.basket_items << BasketItem.new(product: product, quantity: 1)
      basket.set_product_quantities(product.id => 0)
      expect(basket.basket_items.count).to eq 0
    end
  end

  describe '#quantity_of_product' do
    let!(:basket) { FactoryGirl.create(:basket) }
    let(:product) { FactoryGirl.create(:product) }

    context 'with product in basket' do
      it 'returns the quantity of that product' do
        basket.add(product, [], 1)
        expect(basket.quantity_of_product(product)).to eq 1
      end
    end

    context 'without product in basket' do
      it 'returns 0' do
        expect(basket.quantity_of_product(product)).to eq 0
      end
    end
  end

  describe '#weight' do
    it 'returns the sum of the weight of all basket items' do
      item1 = double(BasketItem, weight: 5)
      item2 = double(BasketItem, weight: 10)
      basket = Basket.new
      allow(basket).to receive(:basket_items).and_return [item1, item2]
      expect(basket.weight).to eq 15
    end
  end

  describe '#empty?' do
    let(:basket) { Basket.new }

    context 'when the basket has some items' do
      before do
        basket.basket_items << BasketItem.new
      end

      it 'returns false' do
        expect(basket.empty?).to be_falsey
      end
    end

    context 'when the basket has no items' do
      it 'returns true' do
        expect(basket.empty?).to be_truthy
      end
    end
  end
end
