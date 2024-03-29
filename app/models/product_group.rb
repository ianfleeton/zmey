# == Product Group
#
# Represents a logical grouping of products that share commonality such as
# discounts or location of warehouse.
#
# === Attributes
#
# +location+::
#   Where this product's stock is located, such as a particular warehouse.
# +name+::
#   A descriptive name for the product group.
class ProductGroup < ApplicationRecord
  # Associations
  belongs_to :location, optional: true
  has_many :product_group_placements, dependent: :delete_all
  has_many :products, through: :product_group_placements

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name

  # Delegated methods
  delegate :name, to: :location, prefix: true, allow_nil: true

  def to_s
    name
  end
end
