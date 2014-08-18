source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'
gem 'mysql2'
gem 'RedCloth'
gem 'image_science'
gem 'RubyInline'
gem 'liquid'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'exception_notification'
gem 'slim'
gem 'factory_girl_rails'

# Run jobs in the background
gem 'daemons'
gem 'delayed_job_active_record'

# Pagination
gem 'will_paginate'
gem 'bootstrap-will_paginate'

# Simplify cloning of Active Record objects
gem 'deep_cloneable', '~> 2.0.0'

# Monitor with New Relic
gem 'newrelic_rpm'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc


group :development do
  gem 'brakeman'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/jonleighton/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard-rspec', require: false

  gem 'thin'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', group: :development
gem 'rvm-capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'database_cleaner'
end
