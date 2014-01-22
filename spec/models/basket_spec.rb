require 'spec_helper'

describe Basket do
  describe '#weight' do
    it 'returns the sum of the weight of all basket items' do
      item1 = mock_model(BasketItem, weight: 5)
      item2 = mock_model(BasketItem, weight: 10)
      basket = Basket.new
      basket.stub(:basket_items).and_return [item1, item2]
      expect(basket.weight).to eq 15
    end
  end
end
