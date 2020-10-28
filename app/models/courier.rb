# A company or grouping method that can transport orders for delivery. Includes
# special delivery methods such as collection.
class Courier < ApplicationRecord
  COLLECTION = "Collection"

  # Associations
  has_many :shipments, inverse_of: :courier, dependent: :restrict_with_error

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  def self.collection
    Courier.find_or_create_by(name: COLLECTION)
  end

  def to_s
    name
  end

  # Returns a tracking URL for the given consignment_number so that the customer
  # can track the delivery online. nil is returned if the courier doesn't
  # support tracking URLs.
  def generate_tracking_url(consignment:, postcode:, order_number:)
    return if tracking_url.blank?
    tracking_url
      .gsub("{{order_number}}", order_number)
      .gsub("{{consignment}}", consignment)
      .gsub("{{postcode}}", postcode.gsub(/\s+/, ""))
  end
end
