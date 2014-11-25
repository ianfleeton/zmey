class BasketItem < ActiveRecord::Base
  validates_numericality_of :quantity, greater_than: 0
  validates_presence_of :basket_id

  belongs_to :basket, inverse_of: :basket_items, touch: true
  belongs_to :product
  has_many :feature_selections, -> { order 'id' }, dependent: :delete_all
  before_save :update_features
  before_save :adjust_quantity

  def line_total(inc_tax)
    quantity * (inc_tax ? product_price_inc_tax : product_price_ex_tax)
  end

  # Returns the price of a single product with tax when purchased at
  # the current quantity.
  def product_price_inc_tax
    product.price_inc_tax(quantity)
  end

  # Returns the price of a single product without tax when purchased at
  # the current quantity.
  def product_price_ex_tax
    product.price_ex_tax(quantity)
  end

  def self.describe_feature_selections fs
    fs.map {|fs| fs.description}.join('|')
  end

  # generates a text description of the features the customer has selected and
  # described for this item in the basket
  def update_features
    self.feature_descriptions = BasketItem.describe_feature_selections(feature_selections)
  end

  # Converts quantity to an integer unless product allows a fractional
  # quantity.
  def adjust_quantity
    self.quantity = quantity.ceil unless product.allow_fractional_quantity?
  end

  # Returns the quantity of product in the line. Products that have a
  # fractional quantity (for example, representating weight or area) are
  # counted as 1.
  def counting_quantity
    product.allow_fractional_quantity? ? 1 : quantity
  end

  # Returns the quantity in a type suitable for display. If the product allows
  # a fractional quantity then it's a decimal, otherwise it's an integer.
  def display_quantity
    product.allow_fractional_quantity? ? quantity : quantity.to_i
  end

  def weight
    product.weight * quantity
  end
end
