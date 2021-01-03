# frozen_string_literal: true
module OmniAuth
  module Strategies
    autoload :Misete, 'misete'
  end
end

Rails.application.config.middleware.use(OmniAuth::Builder) do
  provider :google_oauth2, ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET']
  provider :misete, ENV['MISETE_OAUTH_CLIENT_ID'], ENV['MISETE_OAUTH_CLIENT_SECRET'], scope: 'email'
end

def production_url
  heroku_url || 'https://youranime.moe'
end

def heroku_url
  return unless ENV['HEROKU_APP_NAME']

  "https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
end

OmniAuth.config.full_host = ENV.fetch("GOOGLE_OAUTH_REDIRECT_HOST") do
  Rails.env.production? ? production_url : 'http://localhost:3000'
end
