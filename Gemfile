# frozen_string_literal: true
source 'https://rubygems.org'

ruby '3.1.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use ActiveModel has_secure_password
gem 'bcrypt'
# Rest client
gem 'rest-client'
# Shopify's code styles
gem 'rubocop-shopify', require: false
# AWS S3 SDK
gem 'aws-sdk-s3', require: false
# Pagination
gem 'will_paginate'
gem 'will_paginate-bulma'
# Image processing
gem 'image_processing', '~> 1.2'
# ActiveOperation
gem 'active_operation'
# As a state machine (AASM)
gem 'aasm'
# Code quality
gem 'rubocop', require: false
gem 'ruby-lint'
# Tanoshimu Utilities
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
gem 'countries', '~> 3.0'
# For graphql
gem 'graphql', '~> 1.11'

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
