# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Platform < ::Types::BaseObject
        connection_type_class ::Types::Custom::BaseConnection

        field :name, String, null: false
        field :title, String, null: false
        field :colour, String, null: false
        field :image, String, null: false
        field :icon, String, null: false
        field :url, String, null: false
        field :shows, Queries::Types::Show.connection_type, null: false
        field :active_shows, Queries::Types::Show.connection_type, null: false

        field :shows_count, Integer, null: false
        field :active_shows_count, Integer, null: false

        def icon
          "#{context[:hostname]}/img/platforms/#{@object.icon}"
        end

        def image
          "#{context[:hostname]}/img/platforms/#{@object.image}"
        end

        def shows_count
          object.shows.count
        end

        def active_shows_count
          object.active_shows.count
        end
      end
    end
  end
end
