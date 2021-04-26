# frozen_string_literal: true
module Graphql
  class QueryOperation < ApplicationOperation
    property :variables, accepts: Hash, default: -> { {} }
    property :method, accepts: [:get, :post], default: :post
    property! :query, accepts: String
    property! :endpoint, converts: -> (endpoint) do
      return if endpoint.is_a?(URI)

      unless (endpoint = endpoint.to_s) =~ URI.regexp
        raise SmartProperties::ConfigurationError, "Invalid URI: #{endpoint}"
      end

      URI.parse(endpoint)
    end

    def execute
      fetch_data!
    end

    private

    def payload
      { query: query, variables: variables }
    end

    def fetch_data!
      response = RestClient.send(method, endpoint.to_s, payload)
      response = JSON.parse(response)

      response.with_indifferent_access
    end
  end
end
