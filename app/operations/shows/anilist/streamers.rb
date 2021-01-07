# frozen_string_literal: true
module Shows
  module Anilist
    class Streamers < ApplicationOperation
      property! :anilist_id
      property! :show, accepts: Show
      property :persist, accepts: [true, false], default: false

      def perform
        fetch_streaming_platforms_from_anilist
      end

      private

      def query
        'query ($id: Int) {' \
        'Media (id: $id, type: ANIME) {' \
        'externalLinks {' \
        'url site' \
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

      def fetch_streaming_platforms_from_anilist
        Rails.logger.info("[Shows::Anilist::Streamers] GET graphql.anilist.co: ANIME(##{anilist_id})")
        data = fetch_data!.dig(:data, :Media)
        return unless data.present?

        external_links_data = data[:externalLinks]
        return [] unless external_links_data.present?

        external_links_data.map do |external_link_data|
          url = external_link_data[:url]
          site = external_link_data[:site]

          link = ShowUrl.find_by(value: url, show: show)
          next link if link.present?

          link_for(site, url)
        end
      rescue RestClient::Exception => e
        Rails.logger.error(e)
        nil
      end

      def link_for(site, url)
        if site.downcase =~ /official site/
          method = persist ? :create! : :new
          ShowUrl.send(method, url_type: :official, value: url, show: show)
        else
          link = ShowUrl.new(value: url, show: show)
          link.save! if persist

          link.valid? ? link : nil
        end
      end
    end
  end
end
