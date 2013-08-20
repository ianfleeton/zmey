class ShippingZone < ActiveRecord::Base
  belongs_to :website
  has_many :countries, order: 'name', dependent: :nullify
  has_many :shipping_classes, order: 'name', dependent: :destroy

  validates_uniqueness_of :name, scope: :website_id
end
