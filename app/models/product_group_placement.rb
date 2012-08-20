class ProductGroupPlacement < ActiveRecord::Base
  attr_accessible :product_group_id, :product_id

  validates_uniqueness_of :product_id, scope: :product_group_id
  belongs_to :product
  belongs_to :product_group
end
