class Shipment < ActiveRecord::Base
  # Associations
  belongs_to :order

  # Validations
  validates_presence_of :order_id
end
