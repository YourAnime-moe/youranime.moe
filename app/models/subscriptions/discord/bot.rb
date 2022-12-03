require 'discordrb'

module Subscriptions
  module Discord
    class Bot
      attr_reader :command_bot
    
      class << self
        def instance
          @instance ||= Bot.new
        end

        def run(*args)
          instance.run(*args)
        end

        def mark_invisible!
          Rails.logger.info("[Subscriptions::Discord::Bot] Marking bot as invisible")
          instance.command_bot.invisible
        end
      end
    
      def run(*args)
        puts("Invite this bot: #{@command_bot.invite_url(permission_bits: 2048)}")
        @command_bot.run(*args)
      end
    
      private
    
      def initialize
        @command_bot = Discordrb::Commands::CommandBot.new(
          token: Rails.application.credentials.discord[Rails.env].bot_token,
          prefix: '!',
        )
        @command_bot.command(:start) do |event, args|
          channel = event.channel.pm? ? event.channel : event.user.pm
          channel_id = channel.id

          user_subscription = UserSubscription.find_or_initialize_by(
            platform: "discord",
            platform_user_id: channel_id.to_s,
          )

          if user_subscription.persisted?
            event.user.pm("Hey #{event.user.username}, looks you're already good to go!")
          else
            user_subscription.assign_attributes(subscription_type: "airing-info")
            if user_subscription.save
              event.user.pm("Hi #{event.user.username}, welcome! You'll be geting ping from me here.")
            else
              messages = [
                "Hi there #{event.user.username}, looks like something went wrong when setting me up...",
                "Feel free to contact the devs with this error message: `#{user_subscription.errors.to_a.join(' - ')}`"
              ]
              event.user.pm(message.join('\n'))
            end
          end
        end
        @command_bot
      end
    end
  end
end
