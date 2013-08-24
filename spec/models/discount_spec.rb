require 'spec_helper'

describe Discount do
  describe '#uppercase_coupon_code' do
    it 'transforms the coupon attribute to uppercase' do
      discount = Discount.new(coupon: 'Coupon')
      discount.uppercase_coupon_code
      expect(discount.coupon).to eq 'COUPON'
    end
  end
end
