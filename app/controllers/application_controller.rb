class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ApplicationHelper

  def root
    if logged_in?
        redirect_to "/users/#{current_user.username}"
    else
        set_title home: true
        render 'login'
    end
  end

  def login
    redirect_to "/"
  end

  def logout
    log_out
    redirect_to "/"
  end

  def login_post
    username = params[:user][:username]
    password = params[:user][:password]

    user = User.find_by(username: username.downcase)
    unless user.nil?
        if user.authenticate(password)
            log_in user
        else
          flash[:danger] = "Your username or password is wrong. Please try again."
        end
        redirect_to "/"
    else
        flash[:danger] = "Your username or password is wrong. Please try again."
        redirect_to "/"
    end
  end

end
