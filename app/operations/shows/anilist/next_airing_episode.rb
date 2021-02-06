# frozen_string_literal: true
module Shows
  module Anilist
    class NextAiringEpisode < ApplicationOperation
      property! :slug

      def perform
        return if show.blank?
        return unless anilist_id.present?

        return if show.air_complete?

        next_airing_episode_data
      end

      private

      def next_airing_episode_data
        result = fetch_data!
        data = result.dig(:data, :Media, :nextAiringEpisode)

        return unless data.present?

        {
          airing_at: data[:airingAt],
          time_until_airing: data[:timeUntilAiring],
          episode: data[:episode],
        }
      end

      def query
        'query ($id: Int) {' \
        'Media (id: $id, type: ANIME) {' \
        'nextAiringEpisode {' \
        'airingAt timeUntilAiring episode' \
        '}' \
        '}' \
        '}'
      end

      def variables
        { 'id' => anilist_id }
      end

      def payload
        { query: query, variables: variables }
      end

      def fetch_data!
        response = RestClient.post('https://graphql.anilist.co', payload)
        response = JSON.parse(response)

        response.deep_symbolize_keys
      end

      def anilist_id
        show.anilist_id
      end

      def show
        @show ||= Shows::Kitsu::GetBySlug.perform(slug: slug)
      end
    end
  end
end
