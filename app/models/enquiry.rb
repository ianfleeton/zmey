class Enquiry < ActiveRecord::Base
  validates_presence_of :name, :telephone, :email, :enquiry
  validates :website_id, presence: true
  belongs_to :website
end
