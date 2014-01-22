class ShippingClass < ActiveRecord::Base
  belongs_to :shipping_zone
  has_many :shipping_table_rows, -> { order 'trigger_value' }, dependent: :delete_all

  validates_presence_of :name
  validates_presence_of :shipping_zone
  validates_uniqueness_of :name, scope: :shipping_zone_id

  def to_s
    name
  end
end
