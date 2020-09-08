class ApplicationController < ActionController::Base
  helper Webpacker::Helper
  include ApplicationHelper
  include LocaleConcern

  before_action :find_locale
  before_action :check_is_in_maintenance_mode!, except: [:logout]
  before_action :redirect_to_users_home_if_logged_in, only: [:login]

  def admin
    render plain: 'admin panel!'
  end

  def login
    set_title after: t('welcome.text'), before: t('welcome.login.login')
  end

  def misete_auth
    @user = User::MiseteAuth.perform(
      access_token: request.env['omniauth.auth']
    )
    if !@user.persisted?
      set_title(before: t('welcome.user', user: @user.name))
      render 'welcome_misete'
    else
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    end
  rescue User::MiseteAuth::NotMiseteUser => e
    Rails.logger.error e
    redirect_to '/', danger: t('welcome.google.not-google')
  end

  def google_auth
    @user = User::GoogleAuth.perform(
      access_token: request.env['omniauth.auth']
    )
    if !@user.persisted?
      set_title(before: t('welcome.user', user: @user.name))
      render 'welcome_google'
    else
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    end
  rescue User::GoogleAuth::NotGoogleUser => e
    Rails.logger.error e
    redirect_to '/', danger: t('welcome.google.not-google')
  end

  def welcome_google
    @user = current_user
    set_title(before: t('welcome.user', user: @user.name))
  end

  def google_register
    @user = User.new(google_user_params)
    @user.limited = true
    @user.user_type = User::GOOGLE
    @user.active = true
    if @user.save
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    else
      Rails.logger.error @user.errors_string
      render 'welcome_google', alert: @user.errors_string
    end
  end

  def misete_register
    @user = User.new(misete_user_params)
    @user.user_type = User::MISETE
    @user.active = true
    if @user.save
      log_in(@user)
      redirect_to '/', success: t('welcome.login.success.web-message')
    else
      Rails.logger.error @user.errors_string
      render 'welcome_misete', alert: @user.errors_string
    end
  end

  def logout
    log_out
    redirect_to '/'
  end

  def login_post
    user = User::Login.perform(
      username: params[:username].strip.downcase,
      password: params[:password].strip,
      fingerprint: params[:fingerprint]
    )
    log_in(user)
    render json: { new_url: '/', message: t('welcome.login.success.web-message'), success: true }
  rescue User::Login::LoginError => e
    render json: { message: e.message }
  end

  def locale
    render json: { success: true, locale: I18n.locale }
  end

  private

  def redirect_to_users_home_if_logged_in
    return unless logged_in?

    redirect_to '/users/home'
  end

  def google_user_params
    params.require(:user).permit(
      :name,
      :username,
      :email,
      :password,
      :password_confirmation,
      :google_refresh_token,
      :google_token
    )
  end

  def misete_user_params
    params.require(:user).permit(
      :name,
      :username,
      :email,
      :password,
      :password_confirmation,
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
