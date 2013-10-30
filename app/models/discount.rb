class Discount < ActiveRecord::Base
  belongs_to :website
  belongs_to :product_group

  validates :name, presence: true
  validates :website_id, presence: true

  before_save :uppercase_coupon_code

  def to_s
    name
  end

  def uppercase_coupon_code
    coupon.upcase!
  end
end
