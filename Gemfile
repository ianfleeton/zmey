source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.2.2"
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

gem 'RedCloth'
gem 'image_science'
gem 'RubyInline'
gem 'liquid', '~> 3.0'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'exception_notification'
gem 'nilify_blanks'
gem 'slim'
gem 'render_anywhere'

# Run jobs in the background
gem 'daemons'
gem 'delayed_job_active_record'
gem 'whenever', require: false

# Bootstrap for admin area
gem 'bootstrap-sass', '~> 3.4.1'
gem 'bootstrap_form'

# Pagination
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Look up addresses by postcode
gem 'postcode_software', '~> 0.0.1'

# Simpler HTTP requests
gem 'curb'

# Ajax.org Cloud9 Editor (Ace) for the Rails 3.1+ asset pipeline
gem 'ace-rails-ap'

# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
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
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm', git: 'https://github.com/capistrano/rvm.git'
  gem 'capistrano-passenger'
  gem 'capistrano3-delayed-job', '~> 1.0'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
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
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
