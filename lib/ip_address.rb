# frozen_string_literal: true

class IPAddress
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def to_s
    @value
  end

  # Returns a new IP Address that has been anonymized by setting the latter
  # portion to zero.
  def anonymize
    ipv4 = (m = value.match(/\d+\.\d+\.\d+\.\d+$/)) ? m[0] : ""
    ipv6 = value.gsub(ipv4, "")
    ipv6 += ":" if ipv4.present? && ipv6.present?
    ipv4 = ipv4.gsub(/\.\d+$/, ".0")
    ipv6 = ipv6.gsub(/:(\d|[a-f])*:(\d|[a-f])*:(\d|[a-f])*:(\d|[a-f])*:(\d|[a-f])*$/, "::")
    IPAddress.new([ipv6, ipv4].keep_if { |ip| ip.present? }.join)
  end
end
