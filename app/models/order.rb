class Order < ActiveRecord::Base
  validates_presence_of :email_address, :address_line_1, :town_city, :postcode, :country_id
  belongs_to :country
  # Order statuses
  WAITING_FOR_PAYMENT = 1
  PAYMENT_RECEIVED    = 2
  
  def copy_address a
    self.email_address   = a.email_address
    self.full_name       = a.full_name
    self.address_line_1  = a.address_line_1
    self.address_line_2  = a.address_line_2
    self.town_city       = a.town_city
    self.county          = a.county
    self.postcode        = a.postcode
    self.country_id      = a.country_id
    self.phone_number    = a.phone_number
  end
end
