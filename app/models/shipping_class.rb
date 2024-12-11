class ShippingClass < ApplicationRecord
  COLLECTION = "Collection"
  MAINLAND = "Mainland England & Wales"

  belongs_to :shipping_zone
  has_many :shipping_table_rows, -> { order "trigger_value" }, dependent: :delete_all
  has_many :shipping_zones, foreign_key: "default_shipping_class_id", dependent: :nullify
  has_many :websites, foreign_key: "default_shipping_class_id", dependent: :nullify

  validates_presence_of :name
  validates_presence_of :shipping_zone
  validates_uniqueness_of :name, scope: :shipping_zone_id

  TABLE_RATE_METHODS = %w[basket_total weight]
  validates_inclusion_of :table_rate_method, in: TABLE_RATE_METHODS

  # Returns the shipping class that represents customer collection.
  def self.collection
    find_by(name: COLLECTION)
  end

  # Returns truthy if this shipping class represents customer collection.
  def collection?
    name == COLLECTION
  end

  # Returns the shipping class that represents Mainland England & Wales.
  def self.mainland
    find_by(name: MAINLAND)
  end

  # Returns truthy if this shipping class represents Mainland England & Wales.
  def mainland?
    name == MAINLAND
  end

  # Returns the shipping amount for the given shopping. shopping can be any
  # object that responds to #total_for_shipping and #weight, such as a basket
  # or an order.
  #
  # Returns 0 if the shipping table is empty.
  def amount_for(shopping, delivery_date = nil)
    val = value(shopping)

    shipping = BigDecimal(0)

    unless shipping_table_rows.empty?
      shipping_table_rows.each do |row|
        shipping = row.amount if val >= row.trigger_value
      end
    end

    if delivery_date && shopping.am_delivery? && allows_am_delivery
      shipping += weekday_am_surcharge if delivery_date.on_weekday?
      shipping += saturday_am_surcharge if delivery_date.saturday?
    end

    shipping
  end

  def value(basket)
    case table_rate_method
    when "basket_total"
      basket.total_for_shipping
    when "weight"
      basket.weight
    else
      raise "Unknown table rate method"
    end
  end

  def to_s
    name
  end
end
