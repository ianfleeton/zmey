class ShippingClass < ActiveRecord::Base
  belongs_to :shipping_zone
  validates_presence_of :name
  validates_presence_of :shipping_zone
  validates_uniqueness_of :name, :scope => :shipping_zone_id
end
