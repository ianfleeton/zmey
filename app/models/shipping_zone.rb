class ShippingZone < ActiveRecord::Base
  has_many :countries, -> { order :name }, dependent: :nullify
  has_many :shipping_classes, -> { order "shipping_classes.name" }, dependent: :destroy
  belongs_to :default_shipping_class, class_name: "ShippingClass", optional: true

  validates :name, presence: true
end
