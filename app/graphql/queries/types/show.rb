# frozen_string_literal: true
module Queries
  module Types
    class Show < ::Types::BaseObject
      field :title, String, null: false
      field :description, String, null: false
      field :slug, String, null: false
      field :show_type, String, null: false
      field :popularity, Integer, null: false
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
      field :platforms, [Queries::Types::Shows::Platform], null: false do
        argument :focus_on, String, required: false
      end

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
          rating: @object.age_rating,
          guide: @object.age_rating_guide,
        }
      end
    end
  end
end
