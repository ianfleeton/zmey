class ShippingTableRow < ActiveRecord::Base
  belongs_to :shipping_class
  validates_uniqueness_of :trigger_value, scope: 'shipping_class_id'
end
