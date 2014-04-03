class OrderLine < ActiveRecord::Base
  belongs_to :order

  validates_numericality_of :quantity, greater_than_or_equal_to: 1

  before_save :keep_shipped_in_bounds

  def keep_shipped_in_bounds
    if shipped > quantity
      self.shipped = quantity
    elsif shipped < 0
      self.shipped = 0
    end
  end

  def line_total_net
    product_price * quantity
  end
end
