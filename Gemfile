source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0.rc3'
gem 'mysql2'
gem 'RedCloth'
gem 'image_science'
gem 'RubyInline'
gem 'liquid'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'exception_notification'
gem 'nilify_blanks'
gem 'slim'

# Run jobs in the background
gem 'daemons'
gem 'delayed_job_active_record'
gem 'whenever', require: false

# Pagination
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Monitor with New Relic
gem 'newrelic_rpm'

# Ajax.org Cloud9 Editor (Ace) for the Rails 3.1+ asset pipeline
gem 'ace-rails-ap'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc


group :development do
  gem 'brakeman'

  gem 'spring-commands-rspec'
  gem 'guard-rspec', require: false

  gem 'thin'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Rails Html Sanitizer for HTML sanitization
gem 'rails-html-sanitizer', '~> 1.0'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', group: :development
gem 'rvm-capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'rspec-rails', '~> 3.1.0'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri_20, :mri_21]

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Fixtures
  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'database_cleaner'
end
