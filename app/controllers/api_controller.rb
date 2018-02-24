require 'openssl'
require 'base64'

class ApiController < ApplicationController
	# skip_before_action :vertify_authenticity_token
	protect_from_forgery with: :null_session

    before_action :check_is_in_maintenance_mode

	def token
		username = token_params[:username]
		password = token_params[:password]

		if username.to_s.strip.empty? or password.to_s.strip.empty?
			render json: {token: nil, message: "Please refer to the API documentation (if any).", success: false}
			return
		end

        begin
            username = Base64.urlsafe_decode64 username
            password = Base64.urlsafe_decode64 password
        rescue ArgumentError
            render json: {token: nil, message: "Please send your username and password encoded in Base64 format.", success: false}
            return
        end
		    
        user = User.find_by(username: username)
		if user.nil? or !user.authenticate password
			render json: {token: nil, message: "Invalid username or password.", success: false}
			return
		end
        
        # If the client requests and admin account.
        if params[:admin] == "true" && !user.is_admin?
            render json: {
                rails_message: "Access denied. This action requires to be an admin.",
                message: "Access denied. This action requires to be an admin.",
                show_login: true,
                show_login_message: "Re-login",
                success: false
            }
            return
        end

        if !user.is_activated?
            render json: {
                rails_message: "Please visit the admin console to get started.",
                message: "Please go to the <a href=\"https://my-akinyele-admin.herokuapp.com\" target=\"_blank\">admin console</a> to get started.",
                show_login: true,
                show_login: "Try again",
                success: false
            }
            return
        end

        # Keep generating tokens until no user with that token exists.
        success = true
        if params[:preserve_token] != "true"
            success = user.regenerate_auth_token
        end
 
        if success
			render json: {token: user.auth_token, message: "Welcome, #{user.get_name}!", user: user, success: true}
		else
			render json: {message: "Sorry, our server authenticated you but could not log you in.", success: false}
		end
	end

    def check
        token = token_params[:token]
        if token.to_s.strip.empty?
            render json: {message: "Missing token", success: false}
            return
        end
        user = User.find_by(auth_token: token)
        if user
            json = {success: true, message: "Welcome back, #{user.get_name}!"}
        else
            json = {success: false, message: "It appears you have been logged out. Please re-enter your credentials."}
        end
        render json: json
    end

	private
		def token_params
			params.permit(
				:username,
				:password,
                :token
			)
		end

        def check_is_in_maintenance_mode
            if maintenance_activated?
                render json: {
                    success: false,
                    message: "HaveFun (Tanoshimu) is currently in maintenance mode. We appologize for the inconvience.",
                    maintenance: true,
                }
            end
        end

end
