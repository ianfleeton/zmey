class ShippingTableRow < ActiveRecord::Base
  attr_accessible :amount, :shipping_class_id, :trigger_value

  belongs_to :shipping_class
  validates_uniqueness_of :trigger_value, scope: 'shipping_class_id'
end
