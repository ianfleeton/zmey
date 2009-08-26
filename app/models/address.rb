class Address < ActiveRecord::Base
  attr_protected :user_id
  validates_presence_of :full_name, :email_address, :address_line_1, :town_city, :postcode, :country_id
end
