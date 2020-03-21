class Webhook < ActiveRecord::Base
  belongs_to :website

  EVENTS = %w[image_created image_updated order_created]

  validates_inclusion_of :event, in: EVENTS
  validates_presence_of :url
  validates_presence_of :website_id

  # Triggers any webhooks that are registered for the specified event.
  def self.trigger(event, object)
    hooks = Webhook.where(event: event)
    if hooks.any?
      payload = object.to_webhook_payload(event)
      hooks.each { |h| h.delay.trigger(payload) }
    end
  end

  # Triggers the webhook, sending a POST request to the configured URL with
  # the request body containing a JSONified payload.
  def trigger(payload)
    inject_payload!(payload)
    uri = URI(url)
    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        response = http.post(uri.request_uri, payload.to_json, {"Content-Type" => "application/json"})
        if response.code.to_i != 200
          logger.warn "Webhook responded #{response.code}"
        end
      end
    rescue => e
      logger.warn(e)
    end
  end

  # Adds site URL and event attributes to the payload.
  def inject_payload!(payload)
    payload[:site_url] = website.url
    payload[:event] = event
  end

  def to_s
    "#{event} -> #{url}"
  end
end
