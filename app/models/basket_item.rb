class BasketItem < ActiveRecord::Base
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
end
