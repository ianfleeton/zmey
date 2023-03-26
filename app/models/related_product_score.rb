class RelatedProductScore < ApplicationRecord
  validates_presence_of :product_id, :related_product_id, :score

  belongs_to :product
  belongs_to :related_product, class_name: "Product"
end
