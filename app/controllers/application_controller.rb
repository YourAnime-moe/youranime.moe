class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :redirect_if_old
  before_action :find_locale

  before_action {
    #if logged_in?
    #  logout
    #end
    cont = params["controller"] || params[:controller]
    act = params["action"] || params[:action]
    @par = params
    current_controller(cont) if cont
    current_action(act) if act
    @body_class = "container-fluid"
  }

  include ApplicationHelper

  def root
    if logged_in?
      redirect_to "/users/home"
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

  def google_auth
    access_token = request.env["omniauth.auth"]
    @user = User.from_omniauth(access_token)

    # Check if the user has been registered
    if @user.persisted? && @user.google_user
      log_in(@user)
      redirect_to "/",  success: t('welcome.login.success.web-message')
      return
    elsif @user.persisted?
      redirect_to "/",  "Please login with your username and password."
      return
    end

    refresh_token = access_token.credentials.refresh_token
    @user.google_token = access_token.credentials.token
    @user.google_refresh_token = refresh_token if refresh_token.present?

    begin
      I18n.locale = access_token.locale
    rescue
      p "Invalid locale provided by Google: #{access_token.info.locale}"
    end

    render 'welcome_google'
  end

  def google_register
    @user = User.new(google_user_params)
    @user.limited = true
    @user.google_user = true
    if @user.save
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    else
      p @user.errors_string
      render 'welcome_google', alert: @user.errors_string
    end
  end

  def

  def login
    redirect_to "/"
  end

  def logout
    log_out
    redirect_to "/"
  end

  def login_post
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
        if !user.is_admin? && maintenance_activated?(user: user)
          render json: {message: "Sorry, this site is undergoing maintenance as we speak! Please check back later.", success: false}
          return
        end
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

  def authorized_locales
    %w(en fr ja jp)
  end

  def set_locale
    session[:locale] = params[:locale]
    locale = params[:locale].to_s
    found_locale = false
    authorized_locales.each do |auth_locale|
      if locale.include?(auth)
        locale = auth_locale
        p "Set locale #{auth_locale}"
        found_locale = true
        next
      end
    end
    p "Set locale #{locale}"
    I18n.locale = locale if found_locale
    render json: {success: true, new_locale: I18n.locale}
  end

  def set_locale
    current = params[:locale]
    old = I18n.locale
    reload = false
    if session[:locale].nil? || params[:set_at_first] == 'true'
      session[:locale] = current
      found_locale = false
      authorized_locales.each do |auth_locale|
        if current.include?(auth_locale)
          current = auth_locale
          p "Set locale #{auth_locale}"
          found_locale = true
          next
        end
      end
      p "Set locale #{current}"
      I18n.locale = current if found_locale
      session[:locale] = I18n.locale
      reload = old.to_s != current.to_s
    end
    res = {success: true, reload: reload, locale: {requested: current, old: old, current: I18n.locale}}
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

  def find_locale
    try_to_set = params[:lang] || session[:locale]
    begin
      I18n.locale = try_to_set || :fr
    rescue I18n::InvalidLocale
      p "Invalid locale #{try_to_set}. Defaulting to :fr..."
      I18n.locale = :fr
    end
  end

  def google_user_params
    params.require(:user).permit(
      :name,
      :username,
      :password,
      :password_confirmation,
      :google_refresh_token,
      :google_token
    )
  end

  #def check_is_in_maintenance_mode
  #  if maintenance_activated?
  #    respond_to do |format|
  #      format.html { render 'maintenance_activated' }
  #      format.json {
  #        render json: {
  #            success: false,
  #            message: "HaveFun (Tanoshimu) is currently in maintenance mode. We appologize for the inconvience.",
  #            maintenance: true,
  #        }
  #      }
  #    end
  #  end
  #end

end
