module Api
  module V1
    class AuthApiController < Api::ApplicationController
      before_action :ensure_token

      private

      def ensure_token
        # Get the token
        token = params[:token]
    		raise Api::MissingTokenError.new if token.to_s.strip.empty?

        # Check if the token is valid
        @user = User.find_by_token(token)
        raise Api::InvalidTokenError.new if @user.nil?

        # Check if the user is an admin as per the request
    		is_admin = params[:admin] == "true"
        raise Api::NotAdminError.new unless !is_admin || @user.is_admin?
    		@is_admin = params[:admin] == "true"
      end
    end
  end
end
