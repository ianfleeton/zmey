class Discount < ActiveRecord::Base
  belongs_to :website
  belongs_to :free_products_group, class_name: 'ProductGroup'

  validates_presence_of :name

  before_save :uppercase_coupon_code

  def uppercase_coupon_code
    coupon.upcase!
  end
end
