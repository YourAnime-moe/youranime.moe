# frozen_string_literal: true
module Queries
  class Root < ::Types::BaseObject
    field :browse_all, Queries::Types::Show.connection_type, null: false

    def browse_all
      Show.optimized
    end

    field :streamable_shows, Queries::Types::Show.connection_type, null: false do
      argument :limit, Integer, required: false
      argument :sort_filters, [Queries::Types::Shows::Filter], required: false
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
      argument :tags, [Queries::Types::Shows::Scalars::TagFilter], required: false
    end

    def search(query:, limit: 100, tags: [])
      ::Search.perform(search: query, limit: limit, tags: tags, format: :shows)
    end

    field :show_tags, Queries::Types::Shows::Tag.connection_type, null: false

    def show_tags
      Tag.popular
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

    field :trending, Queries::Types::Show.connection_type, null: false do
      argument :tags, [Queries::Types::Shows::Scalars::TagFilter], required: false
      argument :limit, Integer, required: false
    end

    def trending(tags: [], limit: 20)
      if tags.any?
        Search.perform(tags: tags, limit: limit, format: :shows)
      else
        Show.trending.limit(limit)
      end
    end

    field :country_timezone, Queries::Types::CountryTimezone, null: false

    def country_timezone
      { country: context[:country], timezone: context[:timezone] }
    end

    field :home_page_categories, Queries::Types::HomePageCategory.connection_type, null: false

    def home_page_categories
      [
        { tags: ['shounen', 'adventure'], title: 'Go on an adventure with Shounen anime', key: 'shounen-adventure' },
        { tags: ['comedy'], title: 'Get ready to laugh', key: 'comedy' },
        { tags: ['romance'], title: 'Love is in the air', key: 'romance' },
        { tags: ['slice-of-life'], title: 'Everyday life', key: 'slice-of-life' },
        { tags: ['drama'], title: 'Lots of conflicts (drama)', key: 'drama' },
        { tags: ['psychological'], title: "Psychological anime", key: 'psychological' },
        { tags: ['thriller', 'psychological'], title: "Watch something exciting", key: 'thriller' },
        { tags: ['magic'], title: "Enter the world of magic 💫", key: 'magic' },
        { tags: ['music'], title: "It's all about the music", key: 'music' },
        { tags: ['ecchi', 'comedy'], title: "Sprinkles of fan-service", key: 'ecchi' },
        { tags: ['science-fiction'], title: "Sci-fi anime", key: 'science-fiction' },
        { tags: ['sports'], title: "What's it like to break a sweat?", key: 'sports' },
        { tags: ['horror', 'action'], title: "Dark stuff", key: 'horror' },
        { tags: ['idol'], title: "Idol anime ✨", key: 'idol' },
        { tags: ['isekai', 'adventure'], title: "Let's go to another world!", key: 'isekai' },
      ]
    end
  end
end
