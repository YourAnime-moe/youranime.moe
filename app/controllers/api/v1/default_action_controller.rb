module Api
  module V1
    class DefaultActionController < ApplicationController
      def not_found
        render json: {success: false, message: "404 Not Found."}, status: 404
      end
      
      def home
        render json: {
          success: false,
          message: "Welcome to Tanoshimu API! Please check the documentation.",
          documentation: 'https://github.com/thedrummeraki/tanoshimu'
        }, status: 204
      end
    end
  end
end
