class AdditionalProduct < ActiveRecord::Base
  attr_accessible :additional_product_id, :product_id, :selected_by_default

  belongs_to :product
  belongs_to :additional_product, :class_name => "Product"

  validates_presence_of :product_id
  validates_presence_of :additional_product_id
end
