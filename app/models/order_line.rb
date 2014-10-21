class OrderLine < ActiveRecord::Base
  belongs_to :order, touch: true
  belongs_to :product

  validates_numericality_of :quantity, greater_than_or_equal_to: 1

  before_save :keep_shipped_in_bounds
  before_save :recalculate_order_total

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

  # Combined weight of the products in this order line.
  def weight
    product_weight * quantity
  end

  # Returns the tax percentage applied to the order line.
  def tax_percentage
    if line_total_net == 0
      line_total_net
    else
      tax_amount / line_total_net * 100
    end
  end

  def recalculate_order_total
    order.calculate_total
    order.save
  end
end
