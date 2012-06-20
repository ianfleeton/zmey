class OrderLine < ActiveRecord::Base
  attr_accessible :feature_descriptions, :line_total, :product_id, :product_name, :product_price, :product_sku, :quantity, :tax_amount

  belongs_to :order

  before_save :keep_shipped_in_bounds

  def keep_shipped_in_bounds
    if shipped > quantity
      self.shipped = quantity
    elsif shipped < 0
      self.shipped = 0
    end
  end
end
