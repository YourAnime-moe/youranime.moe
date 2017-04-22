require 'openssl'
require 'base64'

class ApiController < ApplicationController
	# skip_before_action :vertify_authenticity_token
	protect_from_forgery with: :null_session

	def token
		username = token_params[:username]
		password = token_params[:password]

		if username.to_s.strip.empty? or password.to_s.strip.empty?
			render json: {token: nil, message: "Please refer to the API documentation (if any)."}
			return
		end

		username = Base64.urlsafe_decode64 username
		password = Base64.urlsafe_decode64 password

		user = User.find_by(username: username)
		if user.nil? or !user.authenticate password
			render json: {token: nil, message: "Invalid username or password"}
			return
		end

		user.regenerate_auth_token
		render json: {token: user.auth_token, message: "Welcome, #{user.get_name}!"}
	end

	private
		def token_params
			params.permit(
				:username,
				:password
			)
		end

end
