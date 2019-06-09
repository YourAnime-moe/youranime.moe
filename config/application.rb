# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HaveFun
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('app/lib')
    config.autoload_paths << Rails.root.join('app/poros')
    config.autoload_paths << Rails.root.join('app/operations')
    config.force_ssl = Rails.env.production?
    config.assets.precompile += %w[.svg]
    config.active_record.sqlite3.represent_boolean_as_integer = true
    config.generators.javascript_engine = :js
    config.action_controller.default_protect_from_forgery = true
  end
end
