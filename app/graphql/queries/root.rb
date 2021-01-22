# frozen_string_literal: true
module Queries
  class Root < ::Types::BaseObject
    field :trending, Queries::Types::Show.connection_type, null: false
    field :top_platforms, Queries::Types::Shows::Platform.connection_type, null: false
    field :show, Queries::Types::Show, null: true do
      argument :slug, String, required: true
    end

    def top_platforms
      ShowUrl.popular_platforms.map do |platform_name|
        Platform.find_by(name: platform_name)
      end.compact
    end

    def trending
      Show.trending.includes(:title_record).limit(100)
    end

    def show(slug:)
      Shows::Kitsu::GetBySlug.perform(slug: slug)
    end
  end
end
