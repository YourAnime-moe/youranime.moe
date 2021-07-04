# frozen_string_literal: true
module Crawl
  class Funimation < ApplicationOperation
    property! :show
    property :season, default: 1

    def execute
      return unless funimation?

      puts "URL: #{service_url}"

      response = RestClient.get(service_url)
      return unless response.code == 200

      JSON.parse(response.body)['episodes']
    end

    private

    def funimation?
      show.platforms.where(name: 'funimation').any?
    end

    def crawl_service_host
      ENV['CRAWL_SERVICE_HOST'] || 'http://localhost:3002'
    end

    def service_url
      "#{crawl_service_host}/funimation?#{{ url: url, season: season }.to_query}"
    end

    def url
      @url ||= show.urls.find_by(url_type: 'funimation').value
    end
  end
end
