module Api
  module V1
    class ShowsController < AuthApiController

      def index
        shows = @user.is_admin? ? Show.ordered : Show.published
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

      def latest
        # Convert the string into an integer. Any invalid
        # integer will be 0. Should this happen, the default
        # value (5) will be used.
        limit = params[:limit].to_i
        limit = 5 if limit < 1

        respond_to do |format|
          format.json { render json: Show.latest(@user, limit: limit) }
        end
      end

    end
  end
end
