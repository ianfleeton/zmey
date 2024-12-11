source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.6"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
gem "acts_as_list"
gem "acts_as_tree"
gem "liquid", "~> 5.5"
gem "nilify_blanks"
gem "render_anywhere"
gem "rmagick"
gem "slim"

gem "whenever", require: false

# Bootstrap for admin area
gem "bootstrap", "~> 5.3"
gem "bootstrap_form", "~> 5.4"

# Authentication and related security policies
gem "devise"

# Pagination
gem "will_paginate"
gem "bootstrap-will_paginate"

# Look up addresses by postcode
gem "postcode_software", "~> 0.0.3"

# Simpler HTTP requests
gem "curb"

# Stripe
gem "stripe"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "mission_control-jobs"

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

group :development, :test do
  gem "rspec-rails"

  # Fixtures
  gem "factory_bot_rails"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]

  # Standard - Ruby style guide, linter, and formatter
  gem "standard"
end

group :development do
  gem "brakeman", "~> 6.2.2"

  gem "guard-rspec", require: false

  #  Run specs in parallel
  gem "parallel_tests", group: :development

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # Allows stubbing HTTP requests and setting expectations on HTTP requests
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
