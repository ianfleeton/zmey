class Webhook < ActiveRecord::Base
  belongs_to :website

  EVENTS = %w(image_created)

  validates_inclusion_of :event, in: EVENTS
  validates_presence_of :url
  validates_presence_of :website_id

  delegate :domain, to: :website

  # Triggers any webhooks that are registered for the object's website and
  # the specified event.
  def self.trigger(event, object)
    hooks = Webhook.where(website: object.website, event: event)
    if hooks.any?
      payload = object.to_webhook_payload(event)      
      hooks.each { |h| h.trigger(payload) }
    end
  end

  # Triggers the webhook, sending a POST request to the configured URL with
  # the request body containing a JSONified payload.
  def trigger(payload)
    inject_payload!(payload)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.post(uri.request_uri, payload.to_json, {'Content-Type' => 'application/json'})
    end
  end

  # Adds domain and event attributes to the payload.
  def inject_payload!(payload)
    payload[:domain] = domain
    payload[:event] = event
  end
end
