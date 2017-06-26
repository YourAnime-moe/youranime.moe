class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action {
    #if logged_in?
    #  logout
    #end
    @body_class = "container-fluid"
  }

  include ApplicationHelper

  def root
    if logged_in?
        redirect_to "/users/#{current_user.username}"
    else
        set_title after: "Welcome", before: "Login"
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
    username = params[:one].strip.downcase
    password = params[:two].strip

    render json: {message: "Hey, we can't log you in if you are silent!"} if username.size == 0 && password.size == 0
    render json: {message: "You forgot your username!"} if password.size > 0 && username.size == 0
    render json: {message: "You forgot your password, <u>#{username}</u>!"} if username.size > 0 && password.size == 0

    return if username.size == 0 || password.size == 0

    user = User.find_by(username: username.downcase)
    unless user.nil?
        if user.authenticate(password)
            log_in user
            render json: {new_url: "/", success: true}
        else
          render json: {message: "Sorry <u>#{username}</u>, but your password is wrong. Please try again!"}
        end
    else
      render json: {message: "Sorry, but we don't know a \"<u>#{username}</u>\"... Try again!"}
    end
  end

end
