require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Misete < OmniAuth::Strategies::OAuth2
      option :name, 'misete'

      option :client_options, {
        :site => ENV['MISETE_OAUTH_HOST'],
        :authorize_url => "/oauth/authorize"
      }

      uid { raw_info["uuid"] }

      info do
        {
          email: raw_info["email"],
          first_name: raw_info["first_name"],
          last_name: raw_info["last_name"],
          username: raw_info["username"],
          image: raw_info["image"],
          color_hex: raw_info["color_hex"],
          active: raw_info["active"],
          blocked: raw_info["blocked"],
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/me.json').parsed
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
