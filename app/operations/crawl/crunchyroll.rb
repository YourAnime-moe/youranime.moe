# frozen_string_literal: true
module Crawl
  class Crunchyroll < ApplicationOperation
    property! :show
    property :include_all, accepts: [true, false], default: false

    def execute
      return unless crunchyroll?

      response = RestClient.get(service_url)
      return unless response.code == 200

      JSON.parse(response.body)['episodes']
    end

    private

    def crunchyroll?
      show.platforms.where(name: 'crunchyroll').any?
    end

    def crawl_service_host
      ENV['CRAWL_SERVICE_HOST'] || 'http://localhost:3002'
    end

    def service_url
      options = { url: url }
      options.merge!({ name: show.title }) unless include_all

      "#{crawl_service_host}/crunchyroll?#{options.to_query}"
    end

    def url
      @url ||= show.urls.find_by(url_type: 'crunchyroll').value
    end
  end
end
