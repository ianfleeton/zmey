class Address < ActiveRecord::Base
  validates_presence_of :full_name, :email_address, :address_line_1, :town_city, :postcode, :country_id
  validates_format_of :email_address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  belongs_to :country
end
