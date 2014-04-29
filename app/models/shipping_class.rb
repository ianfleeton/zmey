class ShippingClass < ActiveRecord::Base
  belongs_to :shipping_zone
  has_many :shipping_table_rows, -> { order 'trigger_value' }, dependent: :delete_all

  validates_presence_of :name
  validates_presence_of :shipping_zone
  validates_uniqueness_of :name, scope: :shipping_zone_id

  TABLE_RATE_METHODS = %w(basket_total weight)
  validates_inclusion_of :table_rate_method, in: TABLE_RATE_METHODS

  def to_s
    name
  end
end
