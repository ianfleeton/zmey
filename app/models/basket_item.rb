class BasketItem < ActiveRecord::Base
  validates_numericality_of :quantity, greater_than_or_equal_to: 1
  belongs_to :basket, inverse_of: :basket_items, touch: true
  belongs_to :product
  has_many :feature_selections, -> { order 'id' }, dependent: :delete_all
  before_save :update_features

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

  def weight
    product.weight * quantity
  end
end
