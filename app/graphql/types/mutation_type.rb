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

    field :subscribe_to_airing_schedule, GraphQL::Types::Boolean, null: true do
      argument :slug, String, required: true
      argument :subscription_id, Int, required: true
      argument :platform, String, required: false # todo change to enum!
    end

    def subscribe_to_airing_schedule(slug:, subscription_id:)
      return if context[:current_user].blank?

      show = Show.find_by(slug: slug)
      return false if show.next_airing_info.blank?

      subscription = context[:current_user].subscriptions.find_by(subscription_id: subscription_id)
      return false if subscription.blank?

      subscription.build_target(show.next_airing_info).save!
    end
  end
end
