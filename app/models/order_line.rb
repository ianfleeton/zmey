class OrderLine < ActiveRecord::Base
  # Associations
  belongs_to :order, touch: true, inverse_of: :order_lines
  belongs_to :product, optional: true

  # Validations
  validates_numericality_of(
    :product_price,
    greater_than_or_equal_to: -Product::MAX_PRICE,
    less_than_or_equal_to: Product::MAX_PRICE
  )
  validates_numericality_of(
    :quantity,
    greater_than: 0, less_than_or_equal_to: 10_000
  )

  # ActiveRecord callbacks
  before_save :keep_shipped_in_bounds
  after_save :recalculate_order_total
  after_destroy :recalculate_order_total

  # Delegated methods
  delegate :delivery_cutoff_hour, to: :product, allow_nil: true

  def to_s
    "#{quantity} × #{product_name}"
  end

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

  # Returns the tax amount for a single product.
  def product_tax_amount
    tax_amount / quantity
  end

  # Returns the price of a single product with tax applied.
  def product_price_inc_tax
    product_price + product_tax_amount
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

  def calculate_product_price
    product.price_ex_tax(quantity)
  end

  def calculate_tax_amount
    product.tax_amount(quantity) * quantity
  end

  def lead_time
    product.try(:lead_time) || 0
  end

  def recalculate_order_total
    order.reload
    order.calculate_total
    order.save
  end

  # Returns the quantity in a type suitable for display. If there is a product
  # and it allows a fractional quantity then it's a decimal, otherwise it's an
  # integer.
  def display_quantity
    product.try(:allow_fractional_quantity?) ? quantity : quantity.to_i
  end
end
