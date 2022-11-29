require 'discordrb'

module Subscriptions
  module Discord
    class Bot
      attr_reader :command_bot
    
      class << self
        def instance
          @instance ||= Bot.new
        end
      end
    
      private
    
      def initialize
        @command_bot = Discordrb::Commands::CommandBot.new(
          token: Rails.application.credentials.discord_bot_token,
        )
      end
    
      def run(*args)
        @command_bot.run(*args)
      end
    end
  end
end
