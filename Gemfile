source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1.4"
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

gem "acts_as_list"
gem "acts_as_tree"
gem "exception_notification"
gem "liquid", "~> 3.0"
gem "nilify_blanks"
gem "render_anywhere"
gem "rmagick"
gem "slim"

# Run jobs in the background
gem "sidekiq", "~> 6.0"
gem "whenever", require: false

# Bootstrap for admin area
gem "bootstrap", "~> 4.5"
gem "bootstrap_form", "~> 4.5"

# Authentication and related security policies
gem "devise"

# Pagination
gem 'will_paginate'
gem "bootstrap-will_paginate"

# Look up addresses by postcode
gem "postcode_software", "~> 0.0.3"

# Simpler HTTP requests
gem 'curb'

# Stripe
gem "stripe"

# Use Puma as the app server
gem "puma", "~> 5.3"
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem "rspec-rails", "~> 4.0.0.rc1"

  # Fixtures
  gem 'factory_bot_rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Standard - Ruby style guide, linter, and formatter
  gem "standard"
end

group :development do
  gem "brakeman", "~> 4.8.0"

  gem 'spring-commands-rspec'
  gem "pry", "~> 0.12.0"
  gem 'guard-rspec', require: false

  # Run specs in parallel
  gem 'parallel_tests', group: :development

  # Use Capistrano for deployment
  gem "capistrano", "~> 3.16"
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm', git: 'https://github.com/capistrano/rvm.git'
  gem 'capistrano-passenger'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem "listen", "~> 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'

  # Allows stubbing HTTP requests and setting expectations on HTTP requests
  gem "webmock", "~> 3.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
