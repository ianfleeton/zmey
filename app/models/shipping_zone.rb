class ShippingZone < ActiveRecord::Base
  has_many :countries, -> { order :name }, dependent: :nullify
  has_many :shipping_classes, -> { order 'shipping_classes.name' }, dependent: :destroy

  validates :name, presence: true
end
