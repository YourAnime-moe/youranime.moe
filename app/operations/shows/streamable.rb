# frozen_string_literal: true
module Shows
  class Streamable < ApplicationOperation
    property :limit, accepts: Integer, converts: :to_i, default: 100
    property :airing, accepts: [true, false], default: true
    property :country
    property :sort_filters, converts: -> (tags) do
      Array(tags).map do |tag|
        Shows::Filter.find_tag!(tag)
      end
    end

    def execute
      scope = Show.sort(*Array(sort_filters)).streamable
      scope = scope.airing if airing

      scope.uniq.select do |show|
        show.platforms(for_country: country).any?
      end.take(limit)
    end
  end
end
