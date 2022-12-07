# frozen_string_literal: true
module Types
  class MutationType < Types::BaseObject
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end

    field :add_to_main_queue, Queries::Types::Show, null: true do
      argument :slug, String, required: true
    end

    def add_to_main_queue(slug:)
      show = Show.find_by(slug: slug)
      context[:current_user]&.add_show_to_main_queue(show) ? show : nil
    end

    field :remove_from_main_queue, Queries::Types::Show, null: true do
      argument :slug, String, required: true
    end

    def remove_from_main_queue(slug:)
      show = Show.find_by(slug: slug)
      context[:current_user]&.remove_show_from_main_queue(show) ? show : nil
    end

    field :subscribe_to_airing_schedule, Queries::Types::Show, null: true do
      argument :slug, String, required: true
      argument :platform, String, required: false # todo change to enum!
    end

    def subscribe_to_airing_schedule(slug:, platform:)
      return if context[:current_user].blank? || context[:current_user_data].blank?

      show = Show.find_by(slug: slug)
      if show.next_airing_info.blank?
        Rails.logger.info("No airing info")
        return
      end

      oauth_grant = context[:current_user_data][:external_oauth_grants].find do |oauth_grant|
        oauth_grant[:grant_name] == platform
      end

      if oauth_grant.blank?
        Rails.logger.info("No discord account linked")
        return
      end

      subscription = context[:current_user].subscriptions.find_by(
        platform: platform,
        platform_user_id: oauth_grant[:grant_user_id],
      )
      if subscription.blank?
        Rails.logger.info("Discord account was not linked on discord")
        return
      end

      subscription.build_target(show.next_airing_info).save!

      show
    end
  end
end
