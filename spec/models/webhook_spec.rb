require 'spec_helper'

describe Webhook do
  describe '#inject_payload!' do
    let(:webhook) { Webhook.new(website: Website.new) }
    let(:payload) { Hash.new }

    it 'adds the domain attribute' do
      webhook.website.domain = 'example.org'
      webhook.inject_payload!(payload)
      expect(payload[:domain]).to eq webhook.website.domain
    end

    it 'adds the event attribute' do
      webhook.event = 'image_created'
      webhook.inject_payload!(payload)
      expect(payload[:event]).to eq webhook.event
    end
  end
end
