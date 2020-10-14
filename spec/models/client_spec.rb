# frozen_string_literal: true

require "rails_helper"

RSpec.describe Client, type: :model do
  describe "validations" do
    # Minimum of three to allow IPv6 localhost "::1".
    it { should validate_length_of(:ip_address).is_at_least(3).is_at_most(45) }
    it do
      should validate_inclusion_of(:platform).in_array(Client::VALID_PLATFORMS)
    end
    it { should validate_length_of(:user_agent).is_at_most(512) }
  end

  describe ".update" do
    it "creates a new Client when clientable has none" do
      order = Order.new

      Client.update(
        order, ip_address: "127.0.0.0", platform: "ios", user_agent: "Mozilla"
      )

      expect(order.client).to be
      expect(order.client.ip_address).to eq "127.0.0.0"
      expect(order.client.platform).to eq "ios"
      expect(order.client.user_agent).to eq "Mozilla"
    end

    it "updates an existing Client when clientable has one" do
      order = FactoryBot.create(:order)
      order.client = client = FactoryBot.create(:client)

      Client.update(
        order, ip_address: "127.0.0.0", platform: "ios", user_agent: "Mozilla"
      )

      expect(order.client).to eq client
      expect(order.client.ip_address).to eq "127.0.0.0"
      expect(order.client.user_agent).to eq "Mozilla"
      expect(Client.count).to eq 1
    end

    it "defaults to the web platform if unspecified" do
      order = Order.new

      Client.update(order, {})

      expect(order.client.platform).to eq "web"
    end
  end

  describe "IP address anonymization on save" do
    it "anonymizes IP address" do
      anonymized = instance_double(IPAddress, to_s: "192.168.0.0")
      ip_address = instance_double(IPAddress, anonymize: anonymized)

      expect(IPAddress)
        .to receive(:new)
        .with("192.168.0.123")
        .and_return(ip_address)

      client = FactoryBot.build(:client, ip_address: "192.168.0.123", clientable: FactoryBot.create(:order))
      client.save

      expect(client.ip_address).to eq "192.168.0.0"
    end
  end

  describe "#mobile_app?" do
    it "returns true for iOS and Android clients" do
      expect(Client.new(platform: "ios").mobile_app?).to be_truthy
      expect(Client.new(platform: "android").mobile_app?).to be_truthy
    end

    it "returns false for web clients" do
      expect(Client.new(platform: "web").mobile_app?).to be_falsey
    end
  end
end
