class SsoController < ApplicationController

    def create
        omniauth = env['omniauth.auth']
        logger.debug "+++ #{omniauth}"

        user = User.find_by_uid(omniauth['uid'])
        if not user
          # New user registration
          user = User.new(:uid => omniauth['uid'])
        end
        user.email = omniauth['info']['email']
        user.save

        #p omniauth

        # Currently storing all the info
        session[:user_id] = omniauth

        flash[:success] = "Successfully logged in"
        redirect_to root_path
    end

    def failure
        flash[:danger] = params[:message]
    end

end
