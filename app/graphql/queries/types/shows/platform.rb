# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class Platform < ::Types::BaseObject
        field :name, String, null: false
        field :title, String, null: false
        field :colour, String, null: false
        field :image, String, null: false
        field :icon, String, null: false
        field :url, String, null: false
        field :shows, Queries::Types::Show.connection_type, null: false
        field :active_shows, Queries::Types::Show.connection_type, null: false

        def icon
          "#{context[:hostname]}/img/platforms/#{@object.icon}"
        end

        def image
          "#{context[:hostname]}/img/platforms/#{@object.image}"
        end
      end
    end
  end
end
