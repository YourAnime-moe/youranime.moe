module Home
  module Categories
    class FollowingOnDiscord < BaseCategory
      def title_template
        "categories.following_on_discord.title"
      end

      def enabled?
        context[:current_user].try(:uuid).present?
      end

      def shows_override
        next_airing_info_ids = context[:current_user]
          .targets
          .where(targetable_type: 'NextAiringInfo')
          .pluck(:targetable_id)

        return Show.none unless next_airing_info_ids.any?

        Show
          .with_next_airing_info
          .where(next_airing_info: {
            id: next_airing_info_ids,
          })
      end

      def cacheable?
        false
      end
    end
  end
end
