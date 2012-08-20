class ProductPlacement < ActiveRecord::Base
  attr_accessible :page_id, :product_id

  acts_as_list scope: :page
  belongs_to :product
  belongs_to :page
end
