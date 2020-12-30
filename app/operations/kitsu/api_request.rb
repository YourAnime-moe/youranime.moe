# frozen_string_literal: true
module Kitsu
  class ApiRequest < ApplicationOperation
    property! :endpoint, accepts: String
    property :params, accepts: Hash
    property :method, accepts: %w[get post], default: 'get', converts: ->(m) { m.to_s.strip.downcase }

    BASE_URI = 'https://kitsu.io/api/edge'

    def perform
      log_request
      results = RestClient.send(method, request_uri)
      body = JSON.parse(results.body)
      body.deep_symbolize_keys
    rescue RestClient::Exception => e
      Rails.logger.error("[Kitsu::ApiRequest] #{e}")
      nil
    end

    private

    def request_uri
      path = endpoint.start_with?('/') ? endpoint : '/'.concat(endpoint)
      uri = BASE_URI + path
      return uri if params.blank?

      uri.concat("?#{params.to_query}")
    end

    def log_request
      Rails.logger.info("[Kitsu::ApiRequest] #{method.upcase} #{request_uri}")
    end
  end
end
