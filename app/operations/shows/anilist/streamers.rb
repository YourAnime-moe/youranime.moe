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

      def fetch_streaming_platforms_from_anilist
        Rails.logger.info("[Shows::Anilist::Streamers] GET #{anilist_url}")
        html_data = Nokogiri::HTML(RestClient.get(anilist_url))
        nodes = html_data.css('a.external-link')

        nodes.map do |node|
          url = node['href'].strip
          next unless url.present?

          link = ShowUrl.find_by(value: url, show: show)
          next link if link.present?

          if node.text.downcase =~ /official site/
            method = persist ? :create! : :new
            ShowUrl.send(method, url_type: :official, value: url, show: show)
          else
            link = ShowUrl.new(value: url, show: show)
            link.save! if persist

            link.valid? ? link : nil
          end
        end.compact
      rescue RestClient::Exception => e
        Rails.logger.error(e)
        nil
      end

      def anilist_url
        "https://anilist.co/anime/#{anilist_id}"
      end
    end
  end
end
