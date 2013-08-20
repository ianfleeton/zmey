class QuantityPrice < ActiveRecord::Base
  belongs_to :product
  validates_presence_of :product_id
  validates_inclusion_of :quantity, in: 2..10_000, message: 'should be between 2 and 10,000'
  validates_uniqueness_of :quantity, scope: :product_id, message: '({{value}}) is already used in a rule for this product'
end
