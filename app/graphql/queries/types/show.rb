# frozen_string_literal: true
module Queries
  module Types
    class Show < ::Types::BaseObject
      field :title, String, null: false
      field :description, String, null: false
      field :slug, String, null: false
      field :show_type, String, null: false
      field :popularity, Integer, null: false
      field :popularity_percentage, Integer, null: false
      field :banner_url, String, null: false
      field :poster_url, String, null: false
      field :likes, Integer, null: false
      field :dislikes, Integer, null: false
      field :loves, Integer, null: false
      field :rank, Integer, null: true
      field :episodes_count, Integer, null: false
      field :nsfw, GraphQL::Types::Boolean, null: false
      field :age_rating, Queries::Types::Shows::AgeRating, null: false
      field :starts_on, GraphQL::Types::ISO8601DateTime, null: true
      field :ended_on, GraphQL::Types::ISO8601DateTime, null: true
      field :status, Queries::Types::Shows::AiringStatus, null: true
      field :friendly_status, String, null: true
      field :platforms, [Queries::Types::Shows::Platform], null: false do
        argument :focus_on, String, required: false
      end
      field :links, [Queries::Types::Shows::Link], null: false
      field :tags, [Queries::Types::Shows::Tag], null: false
      field :related_shows, [Queries::Types::Show], null: false
      field :title_record, Queries::Types::Shows::Title, null: false

      def likes
        @object.likes_count
      end

      def dislikes
        @object.dislikes_count
      end

      def loves
        @object.loves_count
      end

      def age_rating
        {
          rating: @object.age_rating || 'N/R',
          guide: @object.age_rating_guide,
        }
      end

      def title_record
        @object.title_record || { en: '', jp: '' }
      end

      def description
        @object.description || '- No description -'
      end

      def show_type
        return @object.show_type if @object.show_category.blank?

        "#{@object.show_category}/#{@object.show_type}"
      end

      def friendly_status
        return unless @object.status.present?

        I18n.t("anime.shows.airing_status.#{@object.status}")
      end
    end
  end
end
