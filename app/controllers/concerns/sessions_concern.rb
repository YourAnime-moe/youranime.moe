# frozen_string_literal: true

module SessionsConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?, :log_in, :log_out
  end

  def current_user
    @current_user ||= user_by_session
  end

  def logged_in?
    if maintenance_activated?
      _logout && false
    else
      current_user&.is_activated?
    end
  end

  def log_in(user)
    session[:user_id] = user.id
    Rails.logger.info "User #{user.id} (#{user.username}) is now logged"
  end

  def log_out
    _logout if logged_in?
  end

  private

  def user_by_session
    User.find_by(id: session[:user_id])
  end
end
