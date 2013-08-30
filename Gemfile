source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'
gem 'mysql2'
gem 'RedCloth'
gem 'image_science'
gem 'RubyInline'
gem 'liquid'
gem 'prawn'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'exception_notification'
gem 'slim'

# Monitor with New Relic
gem 'newrelic_rpm'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
gem 'libv8'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'brakeman'
  gem 'thin'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', group: :development
gem 'rvm-capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :test do
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'test-unit', '1.2.3'
  gem 'capybara'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'database_cleaner'

  # Go faster!
  gem 'spork-rails', github: 'A-gen/spork-rails'
  gem 'watchr'
end
