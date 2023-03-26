class BasketItem < ApplicationRecord
  validates_numericality_of :quantity, greater_than: 0

  belongs_to :basket, inverse_of: :basket_items, touch: true
  belongs_to :product
  has_many :feature_selections, -> { order "id" }, dependent: :delete_all, inverse_of: :basket_item
  before_save :update_features
  before_save :adjust_quantity
  before_update :preserve_immutable_quantity

  delegate :apply_shipping?, to: :product, allow_nil: true
  delegate :delivery_cutoff_hour, to: :product
  delegate :lead_time, to: :product
  delegate :name, to: :product
  delegate :oversize?, to: :product, allow_nil: true
  delegate :sku, to: :product

  def line_total(inc_vat)
    quantity * (inc_vat ? product_price_inc_vat : product_price_ex_vat)
  end

  # Returns the total amount of VAT for this line.
  def vat_amount
    line_total(true) - line_total(false)
  end

  # Returns the savings made on the basket item, taking into account things such
  # as RRP and volume discounts. The strategy is provided by the price
  # calculator.
  def savings(inc_vat:)
    price_calculator.savings(inc_vat: inc_vat)
  end

  # Returns the price of a single product with VAT.
  def product_price_inc_vat
    price_calculator.inc_vat
  end

  # Returns the price of a single product without VAT.
  def product_price_ex_vat
    price_calculator.ex_vat
  end

  def price_calculator
    product.price_calculator(basket_item: self, quantity: quantity)
  end

  def self.describe_feature_selections fs
    fs.map { |fs| fs.description }.join("|")
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
  #
  # Always returns an integer.
  def counting_quantity
    product.allow_fractional_quantity? ? 1 : quantity.to_i
  end

  # Returns the quantity in a type suitable for display. If the product allows
  # a fractional quantity then it's a decimal, otherwise it's an integer.
  def display_quantity
    product.allow_fractional_quantity? ? quantity : quantity.to_i
  end

  # Returns the weight of a single product in this line.
  def product_weight
    price_calculator.weight
  end

  # Returns the combined weight of all products in this line.
  def weight
    product_weight * quantity
  end

  # If quantity is immutable then prevents any changes to quantity attribute.
  # Also prevents immutable quantity being changed to mutable.
  #
  # Using immutable quantity allows an item to be added to the basket with
  # a quantity that cannot be changed later.
  def preserve_immutable_quantity
    self.immutable_quantity = true if immutable_quantity_changed?
    if immutable_quantity? && quantity_changed?
      self.quantity = quantity_was
    end
  end

  # Returns a copy of this basket item and its feature selections.
  def deep_clone
    bi = dup
    bi.save
    feature_selections.each { |fs| bi.feature_selections << fs.dup }
    bi
  end

  # Returns an instance of OrderLine representing this item.
  def to_order_line
    OrderLine.new(
      product_id: product.id,
      product_sku: sku,
      product_name: product.name,
      product_brand: product.brand,
      product_rrp: product.rrp,
      product_price: product_price_ex_vat,
      product_weight: product_weight,
      vat_amount: vat_amount,
      quantity: quantity,
      feature_descriptions: feature_descriptions
    )
  end
end
