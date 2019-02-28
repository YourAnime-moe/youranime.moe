module Api
  module V1
    class EpisodesController < AuthApiController

      def index
        show_id = params[:show_id]
        validate_id! show_id

        show = Show.find(show_id)
        respond_to do |format|
          format.json { render json: @user.episodes_data(show) }
        end
      end

      def show
        id = params[:id]
        validate_id! id

        episode = Show::Show::Episode.find(id)
        respond_to do |format|
          format.json { render json: episode }
        end
      end

      def watched

      end

    end
  end
end
