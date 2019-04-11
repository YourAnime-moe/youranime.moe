source 'https://rubygems.org'

ruby '2.6.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Suggested updates
gem 'nokogiri'
gem "activestorage"
gem "rack"
gem "loofah"
gem "activejob"

# Rollbar
gem 'rollbar'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', git: "https://github.com/rails/rails"
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt'
gem 'coffee-rails'

# Use of Twitter Bootstrap, jQuery things and Materialize SASS
gem 'jquery-ui-rails'
gem 'bootstrap'
gem 'material_icons'

# Template Engine
gem "slim"
gem "slim-rails"

# Single Sign on
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'omniauth-google-oauth2'

# Coveralls
gem 'coveralls', require: false

# AWS S3 SDK
gem "aws-sdk-s3", require: false

# Pagination
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem "kaminari"
gem 'bootstrap4-kaminari-views'

# Image processing
gem 'image_processing', '~> 1.2'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'pry'
  gem 'pry-rails'
end

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'rack-cache', :require => 'rack/cache'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
