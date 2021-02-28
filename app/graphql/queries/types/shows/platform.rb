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
        field :airing_now, Queries::Types::Show.connection_type, null: false
        field :coming_soon, Queries::Types::Show.connection_type, null: false
        field :other_shows, Queries::Types::Show.connection_type, null: false

        field :countries, [Queries::Types::Shows::Platforms::Country], null: true
        field :global, Boolean, null: false

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

        def global
          @object.countries.blank?
        end
      end
    end
  end
end
