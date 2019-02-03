module Api
  require 'api/errors'

  class ApplicationController < ::ApplicationController

    rescue_from Api::ApiError, with: :render_api_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found

    protected

    def find_token!
      # Get the token
      token = params[:token]
  		raise Api::MissingTokenError.new if token.to_s.strip.empty?
    end

    def ensure_token
      token = find_token!

      # Check if the token is valid
      @user = User.find_by_token(token)
      raise Api::InvalidTokenError.new if @user.nil?

      # Check if the user is an admin as per the request
  		is_admin = params[:admin] == "true"
      raise Api::NotAdminError.new unless !is_admin || @user.is_admin?
  		@is_admin = params[:admin] == "true"
    end

    def validate_id!(id)
      return if id.class == Integer

      error = true
      valid = nil
      if id.class == String
        error = false
        valid = !!(id =~ /\A[-+]?[0-9]+\z/)
      end

      raise InvalidIDError.new(error, valid, nil, id) if error || !valid
    end

  	def token_params
  		params.permit(
  			:username,
  			:password,
        :token,
        :with_user
  		)
  	end

    private

    def render_api_error error
      render json: error, status: error.http_status
    end

    def render_record_not_found error
      render json: {message: error, success: false}, status: 404
    end

  end
end
