class Api::Admin::AdminController < ApplicationController
  before_action :set_website_for_api

  def set_website_for_api
    if Rails.env.production?
      # TODO: Look into HTTP Strict Transport Security configuration and
      # document.
      # TODO: Disable keys that are transmitted over an unencrypted connection.
      # upgrade required if not using SSL
      render nothing: true, status: 426 and return unless request.ssl?
    end

    key = authenticate_with_http_basic { |u, p| ApiKey.find_by(key: u) }
    if key
      @website = key.user.managed_website
      render nothing: true, status: 403 unless @website # forbidden
    else
      render nothing: true, status: 401 # unauthorized
    end
  end
end
