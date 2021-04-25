# frozen_string_literal: true
class ApplicationController < ActionController::Base
  helper Webpacker::Helper

  include ApplicationHelper
  include LocaleConcern
  include PartialsConcern

  before_action :find_locale
  before_action :set_timezone
  before_action :redirect_to_home_if_logged_in, only: [:login]

  layout :application_layout

  def login
    set_title(after: t('welcome.text'), before: t('welcome.login.login'))
  end

  def logout
    log_out
    redirect_to(redirect_to_url)
  end

  def login_post
    user = User::Login.perform(
      username: params[:username].strip.downcase,
      password: params[:password].strip,
      fingerprint: params[:fingerprint],
    )
    log_in(user)
    render(json: { new_url: redirect_to_url, message: t('welcome.login.success.web-message'), success: true })
  rescue User::Login::LoginError => e
    render(json: { message: e.message })
  end

  def locale
    render(json: { success: true, locale: I18n.locale })
  end

  protected

  def ensure_logged_in!
    current_user.sessions.create(active_until: 1.week.from_now) if logged_in? && current_user.auth_token.nil?
    return if logged_in?

    next_url = NextLinkFinder.perform(path: request.fullpath)
    redirect_to("/?next=#{CGI.escape(next_url)}")
  end

  def ensure_logging_in_as_admin
    return unless viewing_as_admin?
    return if logged_in?

    redirect_to('/login')
  end

  private

  def redirect_to_url
    params[:next].present? ? params[:next] : '/'
  end

  def redirect_to_home_if_logged_in
    return unless logged_in?

    redirect_to(home_path)
  end

  def application_layout
    return 'no_headers' if params[:action] == 'login'

    logged_in? ? 'authenticated' : 'application'
  end

  def set_timezone
    # if current_user && browser_timezone && browser_timezone.name != current_user.try(:time_zone)
    #   current_user.update_attributes(time_zone: browser_timezone.name) if current_user.try(:time_zone)
    # end
    Time.zone = browser_timezone # current_user ? current_user.try(:time_zone) : browser_timezone
  end
end
