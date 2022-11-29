require 'discordrb'

module Subscriptions
  module Discord
    class Notifier < Subscriptions::BaseNotifier
      def notify(action, model)
        unless user_subscription.platform == "discord"
          Rails.logger.warn("Skipping irrelevant user subscription (#{user_subscription.platform})...")
          return
        end

        if user_subscription.platform_user_id.blank?
          Rails.logger.error("Missing platform user ID.")
          return
        end

        embed = message_embed(action, model)
        if embed
          Subscriptions::Discord::Bot.instance.command_bot.send_message(
            user_subscription.platform_user_id,
            nil,
            false,
            embed,
          )
        end
      end

      private

      def message_embed(action, model)
        if model.is_a?(NextAiringInfo)
          show = model.show
          platforms_info = show.platforms.map(&:title).join(", ").presence || "- streaming platforms unknown -"

          thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
            url: show.poster_url || show.banner_url,
          )

          footer = Discordrb::Webhooks::EmbedFooter.new(
            text: "Information pulled on: #{Date.current}"
          )

          return Discordrb::Webhooks::Embed.new(
            title: "#{show.title}: New episode",
            description: "New episode #{model.episode_number - 1} airs soon. Streams on: #{platforms_info}",
            thumbnail: thumbnail,
            footer: footer,
          )
        end
      end
    end
  end
end

