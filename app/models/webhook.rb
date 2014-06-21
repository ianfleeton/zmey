class Webhook < ActiveRecord::Base
  belongs_to :website

  EVENTS = %w(image_created)

  validates_inclusion_of :event, in: EVENTS
  validates_presence_of :url
  validates_presence_of :website_id

  def trigger(payload)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.post(uri.request_uri, payload, {'Content-Type' => 'application/json'})
    end
  end
end
