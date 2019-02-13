module Api
  module V1
    class UsersController < Api::ApplicationController

      def index
        respond_to do |format|
          format.json { render json: @user }
        end
      end

    end
  end
end
