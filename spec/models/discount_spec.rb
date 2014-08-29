require 'rails_helper'

describe Discount do
  describe '#to_s' do
    it 'returns its name' do
      discount = Discount.new(name: '20% Off')
      expect(discount.to_s).to eq '20% Off'
    end
  end

  describe '#uppercase_coupon_code' do
    it 'transforms the coupon attribute to uppercase' do
      discount = Discount.new(coupon: 'Coupon')
      discount.uppercase_coupon_code
      expect(discount.coupon).to eq 'COUPON'
    end
  end
end
