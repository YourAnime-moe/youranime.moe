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
        field :available_in_my_country, Boolean, null: false
        field :blocked, Boolean, null: false
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

        def countries
          platform_countries = Array(object.countries).split(context[:country]).flatten
          return platform_countries if platform_countries == object.countries

          [context[:country]].concat(platform_countries).flatten
        end

        def blocked
          Array(object.blocked).include?(context[:country])
        end

        def available_in_my_country
          global || object.countries.include?(context[:country])
        end

        def global
          @object.countries.blank?
        end
      end
    end
  end
end
