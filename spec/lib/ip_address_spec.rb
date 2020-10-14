# frozen_string_literal: true

require "rails_helper"

RSpec.describe IPAddress do
  describe "#anonymize" do
    it "anonymizes IPv4 addresses" do
      ip_address = IPAddress.new("192.168.0.123").anonymize
      expect(ip_address.to_s).to eq "192.168.0.0"
    end

    it "anonymizes IPv6 addresses" do
      ip_address = IPAddress.new("2405:204:4083:12ab:34cd:12ab:34c:12ab").anonymize
      expect(ip_address.to_s).to eq "2405:204:4083::"
    end

    it "anonymizes IPv6 addresses that are contain zeros at the end" do
      ip_address = IPAddress.new("2405:204:4083:12ab:34cd:12ab::").anonymize
      expect(ip_address.to_s).to eq "2405:204:4083::"
    end

    it "anonymizes IPv4 mapped IPv6 addresses" do
      ip_address = IPAddress.new("2405:204:4083:12ab:34cd:12ab:192.168.0.123").anonymize
      expect(ip_address.to_s).to eq "2405:204:4083::192.168.0.0"
    end
  end
end
