require 'spec_helper'

describe OrderLine do
  describe '#line_total_net' do
    it 'returns the product price times the quantity' do
      ol = OrderLine.new(product_price: 1.25, quantity: 3)
      ol.line_total_net.should be_within(0.001).of(3.75)
    end
  end
end
