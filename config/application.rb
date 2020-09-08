require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TanoshimuNew
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.autoload_paths << Rails.root.join('app/lib')
    config.autoload_paths << Rails.root.join('app/operations')
    config.autoload_paths << Rails.root.join('lib/tasks')

    # I18n
    config.authorized_locales = %w[en fr ja jp]

    # UI
    config.bulma_version = nil
    config.videojs_version = nil

    # Misc
    config.is_demo = ENV['DEMO'].to_s.downcase.strip == 'true'
    config.is_using_disk_storage = config.active_storage.service == :local
    config.uses_disk_storage = config.active_storage.service == :local
    config.google_client_id = ENV['GOOGLE_OAUTH_CLIENT_ID']

    # Sidekiq
    config.active_job.queue_adapter = :sidekiq

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
