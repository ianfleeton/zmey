class Webhook < ActiveRecord::Base
  belongs_to :website

  EVENTS = %w(image_created)

  validates_inclusion_of :event, in: EVENTS
  validates_presence_of :url
  validates_presence_of :website_id
end
