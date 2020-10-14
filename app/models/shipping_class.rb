class ShippingClass < ActiveRecord::Base
  COLLECTION = "Collection"

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

  def amount_for_basket(basket)
    value = get_value(basket)

    shipping = nil

    unless shipping_table_rows.empty?
      shipping_table_rows.each do |row|
        if value >= row.trigger_value
          shipping = row.amount
        end
      end
    end

    shipping
  end

  def valid_for_basket?(basket)
    valid_for_value?(basket) && valid_for_size?(basket)
  end

  def valid_for_size?(basket)
    allow_oversize? || !basket.oversize?
  end

  def valid_for_value?(basket)
    if invalid_over_highest_trigger?
      get_value(basket) <= shipping_table_rows.last.trigger_value
    else
      true
    end
  end

  def get_value(basket)
    case table_rate_method
    when "basket_total"
      basket.total(true)
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
