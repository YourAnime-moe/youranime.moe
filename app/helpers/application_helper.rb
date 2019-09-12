module ApplicationHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    if maintenance_activated?
      _logout
      false
    else
      !current_user.nil? && current_user.active?
    end
  end

  def log_in(user)
    session[:user_id] = user.id
    session[:user_login_time] = Time.zone.now
    Rails.logger.info "User #{user.name} is now logged"
  end

  def log_out
    _logout if logged_in?
  end

  def is_maintenance_activated?
    ENV['TANOSHIMU_MAINTENANCE'] == 'true'
  end

  def maintenance_activated?(user: nil)
    user = current_user || user
    if !user.nil? && is_maintenance_activated?
      !user.admin?
    else
      false
    end
  end

  def app_colour
    '#BE585C'
  end

  def app_title
    @app_title
  end

  def set_title(before: nil, after: nil, reset: true, home: false)
    @app_title = nil if reset
    if @app_title.nil?
      @app_title = 'Private' if home == true
      @app_title = t('app.name') if home == false
    end
    @app_title = "#{before} | #{@app_title}" unless before.nil?
    @app_title << " | #{after}" unless after.nil?
    @app_title
  end

  private

  def _logout
    user = current_user
    session.delete(:user_id)
    session.delete(:current_show_id)
    return if Config.slack_client.nil?

    Config.slack_client.chat_postMessage(channel: '#sign-ins', text: "[SIGN OUT] User #{user.username}-#{user.id} at #{Time.zone.now}.")
  end
end
