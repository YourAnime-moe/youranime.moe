# frozen_string_literal: true
module Shows
  module Anilist
    class NextAiringEpisode < ApplicationOperation
      property! :slug
      property :force, accepts: [true, false], default: false
      property :raw, accepts: [true, false], default: false

      def perform
        return if show.blank?
        return unless anilist_id.present?

        return if show.air_complete?
        return fetch_data! if raw

        current_next_airing_info = show.next_airing_info
        if !force && current_next_airing_info.present? && !current_next_airing_info&.past?
          return current_next_airing_info
        end

        data = fetch_next_airing_episode_data!
        update_show!(data)
      end

      private

      def fetch_next_airing_episode_data!
        result = fetch_data!
        data = result.dig(:data, :Media, :nextAiringEpisode)

        return unless data.present?

        {
          airing_at: data[:airingAt],
          time_until_airing: data[:timeUntilAiring],
          episode: data[:episode],
        }
      end

      def update_show!(data)
        if data.nil?
          show.next_airing_info&.destroy
          return
        end

        options = {
          airing_at: Time.at(data[:airing_at]).to_datetime,
          time_until_airing: data[:time_until_airing],
          episode_number: data[:episode],
          past: false,
        }
        next_airing_info = show.next_airing_info || show.build_next_airing_info

        next_airing_info.assign_attributes(**options)
        next_airing_info.save!

        next_airing_info
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
