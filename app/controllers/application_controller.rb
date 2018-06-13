class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :redirect_if_old
  before_action :check_is_in_maintenance_mode
  before_action :find_locale

  def find_locale
    I18n.locale = params[:lang] || session[:locale] || :en
  end

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
        set_title after: t("welcome.text"), before: t("welcome.login.login")
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

    render json: {message: t('welcome.login.errors.no-username-and-password')} if username.size == 0 && password.size == 0
    render json: {message: t('welcome.login.errors.no-username')} if password.size > 0 && username.size == 0
    render json: {message: t('welcome.login.errors.no-password')} if username.size > 0 && password.size == 0

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
              render json: {new_url: new_url, message: t('welcome.login.success.web-message'),  success: true}
            else
              render json: {new_url: "/", message: t('welcome.login.success.web-message'), success: true}
            end
        else
          render json: {message: t("welcome.login.errors.wrong-password", user: username.downcase)}
        end
    else
      render json: {message: t("welcome.login.errors.unknown-user", attempt: username.downcase)}
    end
  end

  def get_locale
    render json: {success: true, locale: I18n.locale}
  end
 
  def set_locale
    session[:locale] = params[:locale]
    I18n.locale = params[:locale]
    render json: {success: true, new_locale: I18n.locale}
  end

  def set_locale
    current = params[:locale]
    old = I18n.locale
    reload = false
    if session[:locale].nil? || params[:set_at_first] == 'true'
      session[:locale] = current
      I18n.locale = current
      reload = old.to_s != current.to_s
    end
    res = {success: true, reload: reload, locale: {requested: current, old: old}}
    p "After locale is set: #{res}"
    render json: res
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
