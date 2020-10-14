require "rails_helper"

RSpec.describe Discount, type: :model do
  describe "associations" do
    it { should have_many(:discount_uses).dependent(:delete_all) }
  end

  describe "validations" do
    it { should validate_numericality_of(:reward_amount).is_less_than_or_equal_to(9999999.999).is_greater_than_or_equal_to(0) }
    it { should validate_inclusion_of(:reward_type).in_array(Discount::REWARD_TYPES) }
    it { should validate_numericality_of(:threshold).is_less_than_or_equal_to(9999999.999).is_greater_than_or_equal_to(0) }
  end

  describe "#to_s" do
    it "returns its name" do
      discount = Discount.new(name: "20% Off")
      expect(discount.to_s).to eq "20% Off"
    end
  end

  describe "#uppercase_coupon_code" do
    it "transforms the coupon attribute to uppercase" do
      discount = Discount.new(coupon: "Coupon")
      discount.uppercase_coupon_code
      expect(discount.coupon).to eq "COUPON"
    end
  end
end
