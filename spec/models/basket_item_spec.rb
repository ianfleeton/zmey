require 'spec_helper'

describe BasketItem do
  describe '#weight' do
    it 'returns the weight of the product times the quantity' do
      product = mock_model(Product, {weight: 2.5})
      item = BasketItem.new(quantity: 3)
      item.product = product
      item.weight.should == 7.5
    end
  end
end
