class OrderComment < ApplicationRecord
  validates_presence_of :order_id

  belongs_to :order, inverse_of: :order_comments
end
