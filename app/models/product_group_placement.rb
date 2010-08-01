class ProductGroupPlacement < ActiveRecord::Base
  validates_uniqueness_of :product_id, :scope => :product_group_id
  belongs_to :product
  belongs_to :product_group
end
