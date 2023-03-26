class ProductPlacement < ApplicationRecord
  acts_as_list scope: :page
  belongs_to :product
  belongs_to :page
end
