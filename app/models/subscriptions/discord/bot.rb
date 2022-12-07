require 'discordrb'

module Subscriptions
  module Discord
    class Bot
      attr_reader :command_bot
    
      class << self
        def send(user_subscription, embed)
          if user_subscription.destination_id.blank?
            Rails.logger.error("Missing platform user ID.")
            return
          end

          payload = {
            channel_id: user_subscription.destination_id,
            embed: embed.to_hash,
          }

          jwt_token = JWT.encode(
            payload,
            Rails.application.credentials.discord[Rails.env].bot_token,
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
