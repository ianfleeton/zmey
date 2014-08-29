require 'rails_helper'

describe Order do
  describe '#to_s' do
    it 'returns its order number' do
      o = Order.new(order_number: '123')
      expect(o.to_s).to eq '123'
    end
  end
end
