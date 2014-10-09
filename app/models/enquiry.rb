# == Enquiry
#
# Customer enquiry form for the store.
#
# === Attributes
#
# Most attributes are requested from the customer in the enquiry form. These are:
#
# * +address+
# * +call_back+ -- Whether and when the customer would like to be phoned by the merchant.
# * +email+
# * +enquiry+
# * +fax+
# * +hear_about+ -- How the customer heard about the shop.
# * +name+
# * +organisation+ -- Organisation the customer belongs to (such as a company).
# * +postcode+
# * +telephone+
#
# Of these, +name+, +telephone+, +email+ and +enquiry+ are required. The
# designer is free to customise the form view and leave out other fields that
# are unnecessary.
#
# === Associations
#
# +website+::
#   Website the customer was using to send the enquiry.
class Enquiry < ActiveRecord::Base
  validates_presence_of :name, :telephone, :email, :enquiry
  validates :website_id, presence: true
  belongs_to :website
end
