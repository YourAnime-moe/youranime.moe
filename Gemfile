# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.6.7'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Suggested updates
gem 'activejob'
gem 'activestorage'
gem 'loofah'
gem 'nokogiri'
gem 'rack'

# Rollbar
gem 'rollbar'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
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
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt'
gem 'rest-client'

# Single Sign on
gem 'omniauth-google-oauth2'
gem 'omniauth-oauth2'
gem 'omniauth-rails_csrf_protection'

# Shopify's code styles
gem 'rubocop-shopify', require: false

# Slack client
gem 'slack-ruby-client'

# Coveralls
gem 'coveralls', require: false

# AWS S3 SDK
gem 'aws-sdk-s3', require: false

# Pagination
gem 'will_paginate'
gem 'will_paginate-bulma'

# Image processing
gem 'image_processing', '~> 1.12'

# Subtitle parsing
gem 'webvtt'

# ActiveOperation
gem 'active_operation'

# As a state machine (AASM)
gem 'aasm'

# Code quality
gem 'debride'
gem 'fasterer'
gem 'reek'
gem 'rubocop', require: false
gem 'ruby-lint'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# My gems
gem 'tanoshimu_utils'

# Downloading files
gem 'down', '~> 5.0'

# Sidekiq
gem 'sidekiq'

# ViewComponent
gem 'view_component', require: 'view_component/engine'

# Frozen record
gem "frozen_record", "~> 0.20.1"

# All things about countries
gem 'countries'

# For graphql
gem 'graphql'
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 4'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Use sqlite3 as the database for Active Record
  gem 'pry'
  gem 'pry-rails'
  gem 'sqlite3'

  # Use GraphiQL
  gem 'graphiql-rails'
end

group :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec'
  gem 'rspec_junit_formatter'
end

group :production do
  gem 'pg'
  gem 'rack-cache', require: 'rack/cache'
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
