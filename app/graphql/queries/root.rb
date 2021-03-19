# frozen_string_literal: true
module Queries
  class Root < ::Types::BaseObject
    field :browse_all, Queries::Types::Show.connection_type, null: false

    def browse_all
      Show.optimized
    end

    field :streamable_shows, Queries::Types::Show.connection_type, null: false do
      argument :limit, Integer, required: false
      argument :filters, [Queries::Types::Shows::Filter], required: false
      argument :direction, [GraphQL::Types::Boolean], required: false
      argument :airing, GraphQL::Types::Boolean, required: false
      argument :region_locked, GraphQL::Types::Boolean, required: false
    end

    def streamable_shows(**args)
      params = {
        country: (context[:country] if args.delete(:region_locked)),
      }.merge(args)
      Shows::Streamable.perform(**params)
    end

    field :search, Queries::Types::Show.connection_type, null: false do
      argument :query, String, required: true
      argument :limit, Integer, required: false
    end

    def search(query:, limit: 100)
      ::Search.perform(search: query, limit: limit, format: :shows)
    end

    field :show, Queries::Types::Show, null: true do
      argument :slug, String, required: true
    end

    def show(slug:)
      Shows::Kitsu::GetBySlug.perform(slug: slug)
    end

    field :next_airing_episode, Queries::Types::Shows::AiringSchedule, null: true do
      argument :slug, String, required: true
    end

    def next_airing_episode(slug:)
      Shows::Anilist::NextAiringEpisode.perform(slug: slug)
    end

    field :top_platforms, Queries::Types::Shows::Platform.connection_type, null: false do
      argument :region_locked, Boolean, required: false
    end

    def top_platforms(region_locked: false)
      options = {}
      options[:for_country] = context[:country] if region_locked

      ShowUrl.popular_platforms(**options)
    end

    field :platform, Queries::Types::Shows::Platform, null: true do
      argument :name, String, required: true
    end

    def platform(name:)
      Platform.find_by(name: name)
    end

    field :trending, Queries::Types::Show.connection_type, null: false

    def trending
      Show.trending.includes(:title_record).limit(100)
    end

    field :country_timezone, Queries::Types::CountryTimezone, null: false

    def country_timezone
      { country: context[:country], timezone: context[:timezone] }
    end
  end
end
