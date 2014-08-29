require 'rails_helper'

describe OrderLine do
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }

  describe '#line_total_net' do
    it 'returns the product price times the quantity' do
      ol = OrderLine.new(product_price: 1.25, quantity: 3)
      expect(ol.line_total_net).to be_within(0.001).of(3.75)
    end
  end
end
