module Api
  module V1
    class ShowsController < AuthApiController

      def index
        shows = @user.is_admin? ? Show.all : Show.published
        respond_to do |format|
          format.json { render json: shows }
        end
      end

      def show
        id = params[:id]
        validate_id! id

        show = Show.find(id)
        respond_to do |format|
          format.json { render json: show }
        end
      end

      def search
        # No need to worry about SQL injections hehe.
        # We don't do database manipulation here :{} :p
        query = params[:query]
        shows = Show.search(query)

        respond_to do |format|
          format.json { render json: shows }
        end
      end

    end
  end
end
