source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0.rc1'
# Use postgresql as the database for Active Record
gem 'pg'

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
gem 'bootstrap-sass', '~> 3.3.3'
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
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', github: "rails/sass-rails"

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development do
  gem 'brakeman', '~> 3.0.0'

  gem 'spring-commands-rspec'
  gem 'guard-rspec', require: false

  gem 'thin', platforms: :ruby

  # Run specs in parallel
  gem 'parallel_tests', group: :development
end

group :development, :test do
  gem 'rspec-rails', '~> 3.5.2'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'

  # Fixtures
  gem 'factory_bot_rails'
end

group :development do
  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm', git: 'https://github.com/capistrano/rvm.git'
  gem 'capistrano-passenger'
  gem 'capistrano3-delayed-job', '~> 1.0'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
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
  gem 'database_cleaner'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
