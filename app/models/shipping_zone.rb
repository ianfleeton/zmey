class ShippingZone < ActiveRecord::Base
  belongs_to :website
  has_many :countries, -> { order :name }, dependent: :nullify
  has_many :shipping_classes, -> { order 'shipping_classes.name' }, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :website_id }
  validates :website_id, presence: true
end
