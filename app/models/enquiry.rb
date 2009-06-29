class Enquiry < ActiveRecord::Base
  validates_presence_of :name, :telephone, :email, :enquiry
end
