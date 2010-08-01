class ProductGroup < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :website_id

  attr_protected :website_id

  has_many :product_group_placements
  has_many :products, :through => :product_group_placements
end
