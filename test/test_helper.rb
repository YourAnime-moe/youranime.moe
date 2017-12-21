ENV['RAILS_ENV'] ||= 'test'
require 'coveralls'
Coveralls.wear!

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
