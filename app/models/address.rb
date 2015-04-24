class Address < ActiveRecord::Base
  validates_presence_of :full_name, :email_address, :address_line_1, :town_city, :postcode, :country_id
  validates_format_of :email_address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  belongs_to :country
  belongs_to :user

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

  def to_s
    label
  end
end
