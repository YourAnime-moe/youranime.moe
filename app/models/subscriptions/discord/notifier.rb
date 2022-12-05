require 'discordrb'

module Subscriptions
  module Discord
    class Notifier < Subscriptions::BaseNotifier
      def notify(action, model, changes)
        unless user_subscription.platform == "discord"
          Rails.logger.warn("Skipping irrelevant user subscription (#{user_subscription.platform})...")
          return
        end

        if user_subscription.platform_user_id.blank?
          Rails.logger.error("Missing platform user ID.")
          return
        end

        embed = message_embed(action, model, changes)
        if embed
          Subscriptions::Discord::Bot.send(
            {
              channel_id: user_subscription.platform_user_id,
              embed: embed.to_hash,
            }
          )
        end
      end

      private

      def message_embed(action, model, changes)
        if model.is_a?(NextAiringInfo)
          show = model.show
          platforms_info = show.platforms.map(&:title).join(", ").presence || "- streaming platforms unknown -"

          thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
            url: show.poster_url || show.banner_url,
          )

          footer = Discordrb::Webhooks::EmbedFooter.new(
            text: "Airs: #{model.airing_at}"
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

