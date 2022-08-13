module Api
  module V1
    class MediaController < ApplicationController
      protected
      
      def media_params
        params.permit(
          :search,
        )
      end
    end
  end
end
