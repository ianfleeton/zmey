class Webhook < ActiveRecord::Base
  belongs_to :website

  validates_presence_of :event
  validates_presence_of :url
  validates_presence_of :website_id
end
