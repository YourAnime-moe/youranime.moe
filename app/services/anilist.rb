require "graphql/client"
require "graphql/client/http"

module Anilist
  HTTP = GraphQL::Client::HTTP.new("https://graphql.anilist.co")
  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
