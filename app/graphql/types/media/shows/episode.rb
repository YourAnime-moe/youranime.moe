# frozen_string_literal: true

module Types
  module Media
    module Shows
      class Episode < BaseObject
        field :id, ID, null: false
        field :season_id, ID, null: false
        field :number, Int, null: false
        field :title, String, null: false
        field :duration, Float, null: false
        field :views, Int, null: false
        field :thumbnail_url, String, null: true
        field :captions_url, String, null: true
        field :video_url, String, null: true

        field :season, Season, null: false
        field :show, Show, null: false
        field :show_id, ID, null: false

        def season
          @object.season
        end

        def show
          @object.season.show
        end

        def show_id
          @object.season.show.id
        end
      end
    end
  end
end

