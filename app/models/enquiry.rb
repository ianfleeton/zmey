class Enquiry < ActiveRecord::Base
  attr_accessible :address, :call_back, :country, :email, :fax, :hear_about, :name, :organisation, :postcode, :telephone, :website_id

  validates_presence_of :name, :telephone, :email, :enquiry
  belongs_to :website
end
