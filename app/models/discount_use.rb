class DiscountUse < ApplicationRecord
  # Associations
  belongs_to :discount
  belongs_to :order
end
