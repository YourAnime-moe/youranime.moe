class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :redirect_if_old
  before_action :check_is_in_maintenance_mode

  before_action {
    #if logged_in?
    #  logout
    #end
    cont = params["controller"] || params[:controller]
    act = params["action"] || params[:action]
    @par = params
    current_controller(cont) if cont
    current_action(act) if act
    p "Params: #{@par.to_h}"
    @body_class = "container-fluid"
  }

  include ApplicationHelper

  def root
    if logged_in?
        redirect_to "/users/#{current_user.username}"
    else
        set_title after: "Welcome", before: "Login"
        @params = {}
        params.each do |k, v|
          next if k == "controller" || k == "action"
          @params[k] = v
        end
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
    p params.to_h
    username = params[:username].strip.downcase
    password = params[:password].strip

    controller = params[:ccontroller]
    action = params[:caction]

    render json: {message: "Hey, we can't log you in if you are silent!"} if username.size == 0 && password.size == 0
    render json: {message: "You forgot your username!"} if password.size > 0 && username.size == 0
    render json: {message: "You forgot your password, <u>#{username}</u>!"} if username.size > 0 && password.size == 0

    return if username.size == 0 || password.size == 0

    user = User.find_by(username: username.downcase)
    unless user.nil?
        if user.authenticate(password)
            user.regenerate_auth_token if user.auth_token.nil?
            unless user.is_activated?
              render json: {message: 'Please go to the <a href="https://my-akinyele-admin.herokuapp.com" target="_blank">admin console</a> to get started.', success: false}
              return
            end
            log_in user
            if controller && action
              p "Alternate url detected: c = #{controller} - a = #{action}"
              begin
                new_url = url_for controller: controller, action: action, only_path: true
              rescue ActionController::UrlGenerationError => e
                warn "Error: #{e}"
                new_url = "/"
              end
              new_url += "?"
              params.each do |k, v|
                if !k.to_s.include?("controller") && !k.to_s.include?("action") && k != "username" && k != "password"
                  new_url += "#{k}=#{v}&"
                end
              end
              p "New url: #{new_url}"
              render json: {new_url: new_url, success: true}
            else
              render json: {new_url: "/", success: true}
            end
        else
          render json: {message: "Sorry <u>#{username}</u>, but your password is wrong. Please try again!"}
        end
    else
      render json: {message: "Sorry, but we don't know a \"<u>#{username}</u>\"... Try again!"}
    end
  end

  protected

  def redirect_if_old
    if request.host == 'tanoshimu.herokuapp.com'
      redirect_to "https://anime.akinyele.ca#{request.fullpath}", :status => :moved_permanently
    end
  end

  private

  def check_is_in_maintenance_mode
    if maintenance_activated?
      render 'maintenance_activated'
    end
  end

end
