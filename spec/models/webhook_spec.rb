require 'rails_helper'

describe Webhook do
  describe '#inject_payload!' do
    let(:webhook) { Webhook.new(website: Website.new) }
    let(:payload) { Hash.new }

    it 'adds the site URL' do
      webhook.website.domain = 'example.org'
      webhook.website.scheme = 'https'
      webhook.website.port = 3000
      webhook.inject_payload!(payload)
      expect(payload[:site_url]).to eq 'https://example.org:3000'
    end

    it 'adds the event attribute' do
      webhook.event = 'image_created'
      webhook.inject_payload!(payload)
      expect(payload[:event]).to eq webhook.event
    end
  end

  describe 'to_s' do
    it 'returns a string containing event and URL' do
      webhook = Webhook.new(event: 'image_updated', url: 'http://example.org')
      expect(webhook.to_s).to eq 'image_updated -> http://example.org'
    end
  end
end
