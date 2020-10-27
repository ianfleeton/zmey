# frozen_string_literal: true

class DiscountLine
  SKU = "DISCOUNT"

  attr_accessor :calculator, :discount, :mutually_exclusive_with, :name
  attr_reader :price_adjustment, :tax_adjustment

  def initialize(discount, attrs)
    self.discount = discount
    self.calculator = attrs[:calculator]
    self.mutually_exclusive_with = attrs[:mutually_exclusive_with] || Set.new
    self.name = attrs[:name]
    self.price_adjustment = attrs[:price_adjustment]
    self.tax_adjustment = attrs[:tax_adjustment]
  end

  def price_with_tax(inc_tax)
    if inc_tax
      price_adjustment + tax_adjustment
    else
      price_adjustment
    end
  end

  def price_adjustment=(val)
    @price_adjustment = round(val)
  end

  def tax_adjustment=(val)
    @tax_adjustment = round(val)
  end

  def to_s
    "#{name}: #{price_adjustment} #{tax_adjustment}"
  end

  # Returns an instance of OrderLine representing this discount.
  def to_order_line
    OrderLine.new(
      product_id: 0,
      product_sku: SKU,
      product_name: name,
      product_price: price_adjustment,
      tax_amount: tax_adjustment
    )
  end

  private

  def round(val)
    val.to_f.round(2)
  end
end
