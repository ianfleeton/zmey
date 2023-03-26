class ProductImage < ApplicationRecord
  validates_presence_of :image_id, :product_id

  belongs_to :image
  belongs_to :product

  before_destroy :remove_as_main_image

  after_create :add_as_main_image

  def remove_as_main_image
    if product.image_id == image_id
      product.image_id = nil
      product.save
    end
  end

  def add_as_main_image
    if product.image_id.nil?
      product.image_id = image_id
      product.save!
    end
  end
end
