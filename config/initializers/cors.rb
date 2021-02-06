# frozen_string_literal: true
Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allowed_origins = Rails.application.config.x.cors_allowed_origins.split(',').map(&:strip)
  puts "Allowing CORS origins: #{allowed_origins}"

  allow do
    origins(*allowed_origins)

    resource '*',
      header: 'Content-Type, Authorization',
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
