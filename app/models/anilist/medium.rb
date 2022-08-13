module Anilist
  class Medium
    include SmartProperties

    property :type
    property :format
    property :id
    property :title
    property :description
    property :banner_image
    property :cover_image
    property :start_date
    property :end_date
    property :season
    property :season_year
    property :status
    property :genres
    property :is_adult
    property :average_score
    property :popularity
    property :media_list_entry

    # Anime-specific
    property :episodes
    property :duration
    property :next_airing_episode
    property :studios

    # Manga-specific
    property :chapters
    property :volumes

    class << self
      def build(graphql_medium)
        data = graphql_medium.to_h
        object_as_params_hash = data.deep_transform_keys(&:underscore).symbolize_keys

        new(**object_as_params_hash)
      end
    end


  end
end
