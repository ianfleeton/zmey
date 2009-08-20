class Product < ActiveRecord::Base
  validates_presence_of :name, :sku
  validates_uniqueness_of :sku, :scope => :website_id

  has_many :pages, :through => :product_placement
  belongs_to :image
end
