module Api
  module V1
    class AnimeController < MediaController
      def index
        render_api(
          Anilist::Search.perform(variables: { search: media_params[:search] }),
        )
      end

      def airing
        render_api(
          Anilist::Search.perform(variables: { status: "RELEASING", type: "ANIME" })
        )
      end
    end
  end
end
