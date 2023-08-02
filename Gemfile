source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.3"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"

gem "acts_as_list"
gem "acts_as_tree"
gem "exception_notification"
gem "liquid", "~> 3.0"
gem "nilify_blanks"
gem "render_anywhere"
gem "rmagick"
gem "slim"

# Run jobs in the background
gem "sidekiq", "~> 7.0"
gem "whenever", require: false

# Bootstrap for admin area
gem "bootstrap", "~> 5.0"
gem "bootstrap_form", "~> 5.0"

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
gem "puma", "~> 5.6"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6"

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

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
  gem "brakeman", "~> 5.2.2"

  gem "guard-rspec", require: false

  #  Run specs in parallel
  gem "parallel_tests", group: :development

  # Use Capistrano for deployment
  gem "capistrano-rails"
  gem "capistrano-rvm", git: "https://github.com/capistrano/rvm.git"
  gem "capistrano3-puma", "~> 5.2"

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
  gem "webdrivers"

  # Allows stubbing HTTP requests and setting expectations on HTTP requests
  gem "webmock"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
