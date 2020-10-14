class Address < ActiveRecord::Base
  PLACEHOLDER_EMAIL = "nobody@example.org"

  validates_presence_of :full_name, :email_address, :address_line_1, :town_city, :postcode, :country_id
  validates_format_of :email_address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  belongs_to :country
  belongs_to :user, optional: true

  delegate :shipping_zone, to: :country, allow_nil: true

  before_validation :set_default_label

  def set_default_label
    self.label = "#{full_name} - #{postcode}" if label.blank?
  end

  # Return shipping classes available for this address, or an empty array if
  # there are none.
  def shipping_classes
    shipping_zone.try(:shipping_classes) || []
  end

  # Returns the default shipping class defined by this address's zone, or
  # <tt>nil</tt> if there is no zone or the zone has no default.
  def default_shipping_class
    shipping_zone.try(:default_shipping_class)
  end

  def to_s
    label
  end
end
