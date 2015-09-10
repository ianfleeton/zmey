class Discount < ActiveRecord::Base
  belongs_to :product_group

  validates_numericality_of :reward_amount, greater_than_or_equal_to: 0, less_than_or_equal_to: 9999999.999
  REWARD_TYPES = ['amount_off_order', 'free_products', 'percentage_off', 'percentage_off_order']
  validates_inclusion_of :reward_type, in: REWARD_TYPES

  validates :name, presence: true

  before_save :uppercase_coupon_code

  def to_s
    name
  end

  def uppercase_coupon_code
    coupon.upcase!
  end

  def currently_valid?
    if valid_from.nil? || valid_to.nil?
      true
    else
      Time.zone.now >= valid_from && Time.zone.now <= valid_to
    end
  end
end
