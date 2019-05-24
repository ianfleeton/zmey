require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zmey
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_job.queue_adapter = :delayed_job

    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths << Rails.root.join('app', 'mailers', 'concerns')

    config.assets.paths << ENV['ZMEY_ASSETS'] if ENV['ZMEY_ASSETS']

    require ENV['ZMEY_CONFIG'] if ENV['ZMEY_CONFIG']
  end
end
