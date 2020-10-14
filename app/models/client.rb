# frozen_string_literal: true

# Details of a user's client used to access the website or API.
class Client < ApplicationRecord
  belongs_to :clientable, polymorphic: true

  validates_length_of :ip_address, minimum: 3, maximum: 45
  VALID_PLATFORMS = %w[android ios web].freeze
  validates_inclusion_of :platform, in: VALID_PLATFORMS
  validates_length_of :user_agent, maximum: 512

  before_save :anonymize_ip_address

  def self.update(clientable, params)
    client = clientable.client || Client.new
    client.assign_attributes(
      ip_address: params[:ip_address],
      platform: params[:platform] || "web",
      user_agent: params[:user_agent]
    )
    clientable.client = client
  end

  # Returns true if the client platform is an installed mobile application.
  def mobile_app?
    %(android ios).include? platform
  end

  private

  def anonymize_ip_address
    self.ip_address = IPAddress.new(ip_address).anonymize
  end
end
