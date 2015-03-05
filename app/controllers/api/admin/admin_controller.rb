class Api::Admin::AdminController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :set_website_for_api

  def set_website_for_api
    if Rails.env.production? && remote_connection?
      # TODO: Look into HTTP Strict Transport Security configuration and
      # document.
      # TODO: Disable keys that are transmitted over an unencrypted connection.
      render plain: 'SSL required', status: 403 and return unless request.ssl?
    end

    key = authenticated_api_key
    if key
      @website = key.user.managed_website
      render nothing: true, status: 403 unless @website # forbidden
    else
      render nothing: true, status: 401 # unauthorized
    end
  end

  def authenticated_api_key
    authenticate_with_http_basic { |u, p| ApiKey.find_by(key: u) }
  end

  # Returns +true+ or +false+ if an API parameter is recognised as a boolean
  # value, or +nil+ otherwise. +value+ should be a string as it is expected
  # to be a member of the +params+ hash.
  #
  #   api_boolean('false') # => false
  #   api_boolean('1')     # => true
  #   api_boolean('YES')   # => true
  #   api_boolean('X')     # => nil
  def api_boolean(value)
    {
      '0'     => false,
      'false' => false,
      'no'    => false,
      '1'     => true,
      'true'  => true,
      'yes'   => true
    }[value.try(:downcase)]
  end

  # Returns the default number of items to include in a collection request.
  def default_page_size
    50
  end

  private

    def remote_connection?
      request.remote_ip != '127.0.0.1'
    end
end
