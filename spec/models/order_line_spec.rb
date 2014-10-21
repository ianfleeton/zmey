require 'rails_helper'

describe OrderLine do
  it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }

  describe '#line_total_net' do
    it 'returns the product price times the quantity' do
      ol = OrderLine.new(product_price: 1.25, quantity: 3)
      expect(ol.line_total_net).to be_within(0.001).of(3.75)
    end
  end

  describe '#tax_percentage' do
    it 'returns 0 when the line total is 0' do
      o = OrderLine.new(product_price: 0, quantity: 2)
      expect(o.tax_percentage).to eq 0.0
    end

    it 'returns 20 when the line total is 10 and tax amount 2' do
      o = OrderLine.new(product_price: 5, quantity: 2, tax_amount: 2)
      expect(o.tax_percentage).to eq 20.0
    end
  end
end
