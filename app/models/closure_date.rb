# Represents a date that the merchant is closed for business. The merchant
# cannot dispatch on these dates. Whether the goods can be delivered (that is,
# arrive at the customer's address) depends on the delivery_possible attribute.
# For example, this will be false on a public holiday but true on a day where
# only the merchant is closed for business.
class ClosureDate < ApplicationRecord
  validates_presence_of :closed_on
end
