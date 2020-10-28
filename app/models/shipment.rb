class Shipment < ActiveRecord::Base
  # Associations
  belongs_to :courier, inverse_of: :shipments
  belongs_to :order

  # Validations
  validates_presence_of :order_id

  # Delegated methods
  delegate :name, to: :courier, prefix: true
  delegate :order_number, to: :order

  # Active Record callbacks
  before_save :generate_consignment_number, :generate_tracking_url

  def generate_consignment_number
    return unless needs_consignment_number?
    self.consignment_number =
      courier.consignment_prefix + order.order_number + suffix
  end

  def needs_consignment_number?
    consignment_number.blank? && courier.generate_consignment_number?
  end

  # Generates and assigns a tracking URL if the courier supports them, and if
  # one hasn't already been set.
  def generate_tracking_url
    self.tracking_url ||=
      courier.generate_tracking_url(
        consignment: consignment_number,
        postcode: postcode,
        order_number: order_number
      )
  end

  # Returns the order's delivery postcode, or +nil+ if there is no associated
  # order yet.
  def postcode
    order.try(:delivery_postcode)
  end
end
