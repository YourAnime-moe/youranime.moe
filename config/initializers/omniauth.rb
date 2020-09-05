module OmniAuth
  module Strategies
    autoload :Misete, 'misete'
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET']
  provider :misete, ENV['MISETE_OAUTH_CLIENT_ID'], ENV['MISETE_OAUTH_CLIENT_SECRET'], scope: 'email'
end

OmniAuth.config.full_host = ENV.fetch("GOOGLE_OAUTH_REDIRECT_HOST") {
  Rails.env.production? ? 'https://youranime.moe' : 'http://localhost:3000'
}
