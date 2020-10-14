class LocationOrdersExceededEntry < ApplicationRecord
  # Associations
  belongs_to :location

  # Validations
  validates_presence_of :exceeded_on
end
