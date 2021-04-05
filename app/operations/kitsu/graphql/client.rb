# frozen_string_literal: true
require 'graphql/client'
require 'graphql/client/http'

module Kitsu
  module Graphql
    HTTP = GraphQL::Client::HTTP.new('https://kitsu.io/api/graphql')
    Schema = GraphQL::Client.load_schema(HTTP)
    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end
end
