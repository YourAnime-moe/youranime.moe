# frozen_string_literal: true

module Types
  module Media
    class Show < BaseObject
      field :id, ID, null: false
      field :show_type, Types::Media::ShowType, null: false
      field :dubbed, GraphQL::Types::Boolean, null: false
      field :subbed, GraphQL::Types::Boolean, null: false
      field :published, GraphQL::Types::Boolean, null: false
      field :title_record, Types::Media::TranslableField, null: false
      field :title, String, null: false
      field :description_record, Types::Media::TranslableField, null: false
      field :description, String, null: false
      field :banner_url, String, null: true

      field :seasons_count, Int, null: false
      def seasons_count
        @object.seasons.count
      end
    end
  end
end
