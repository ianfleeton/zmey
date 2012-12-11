require 'spec_helper'

describe Discount do
  describe '#uppercase_coupon_code' do
    it 'transforms the coupon attribute to uppercase' do
      discount = Discount.new(coupon: 'Coupon')
      discount.uppercase_coupon_code
      discount.coupon.should == 'COUPON'
    end
  end
end
