# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_locale
  before_action :check_is_in_maintenance_mode!, except: [:logout]

  include ApplicationHelper

  def root
    if logged_in?
      redirect_to '/users/home'
    else
      set_title after: t('welcome.text'), before: t('welcome.login.login')
      render 'login'
    end
  end

  def google_auth
    google_auth = User::GoogleAuth.perform(
      access_token: request.env['omniauth.auth']
    )
    if google_auth.output
      set_title(before: t('welcome.user', user: @user.name))
      render 'welcome_google'
    else
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    end
  rescue User::GoogleAuth::NotGoogleUser
    redirect_to '/', danger: t('welcome.google.not-google')
  end

  def welcome_google
    @user = current_user
    set_title(before: t('welcome.user', user: @user.name))
  end

  def google_register
    @user = User.new(google_user_params)
    @user.limited = true
    @user.google_user = true
    if @user.save
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    else
      Rails.logger.error @user.errors_string
      render 'welcome_google', alert: @user.errors_string
    end
  end

  def logout
    log_out
    redirect_to '/'
  end

  def login_post
    user = User::Login.perform(
      username: params[:username].strip.downcase,
      password: params[:password].strip
    )
    log_in(user)
    render json: { new_url: '/', message: t('welcome.login.success.web-message'), success: true }
  rescue User::Login::LoginError => e
    render json: { message: t(e.message) }
  end

  def locale
    render json: { success: true, locale: I18n.locale }
  end

  def set_locale
    current = params[:locale]
    old = I18n.locale
    reload = false
    if session[:locale].nil? || params[:set_at_first] == 'true'
      session[:locale] = current
      found_locale = false
      Config.authorized_locales.each do |auth_locale|
        next unless current.include?(auth_locale)

        current = auth_locale
        Rails.logger.info "Set locale #{auth_locale}"
        found_locale = true
        next
      end
      Rails.logger.info "Set locale #{current}"
      I18n.locale = current if found_locale
      session[:locale] = I18n.locale
      reload = old.to_s != current.to_s
    end
    res = { success: true, reload: reload, locale: { requested: current, old: old, current: I18n.locale } }
    render json: res
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

  def check_is_in_maintenance_mode!
    return unless maintenance_activated?

    respond_to do |format|
      format.html { render 'maintenance_activated' }
      format.json do
        render json: {
          success: false,
          message: 'HaveFun (Tanoshimu) is currently in maintenance mode.\
            We appologize for the inconvience.',
          maintenance: true
        }
      end
    end
  end
end
