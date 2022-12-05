require 'discordrb'

module Subscriptions
  module Discord
    class Bot
      attr_reader :command_bot
    
      class << self
        def send(payload)
          jwt_token = JWT.encode(
            payload,
            Rails.application.credentials.discord.development.bot_token,
            'HS512',
          )

          RestClient.post(
            "#{ENV.fetch("BOT_API_HOST") { 'http://bot:9292' }}/webhook/message",
            { jwt_token: jwt_token }.to_json,
          )
        end
      end
    end
  end
end
