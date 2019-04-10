module ApplicationHelper

  def back_index
    {
      from: {
        "history" => "/shows/history"
      },
      title: {
        "history" => "episode history"
      }
    }
  end

  # Return the padded class if the user is logged
  def pad_if_logged_in!
    ('logged-in' if logged_in?).to_s
  end

  def get_back_url(params, default=nil)
    _get_back params, :from, default
  end

  def get_back_title(params, default)
    _get_back params, :title, default
  end

  def _get_back(params, key, default)
    return back_index[key][params[:from]] || default if params[:from]
    default
  end

  def app_title
    @app_title
  end

  def login_time
    return nil unless logged_in?
    @login_time ||= session[:user_login_time]
    return "None" if @login_time.nil?
    Utils.get_date_from_time(Time.parse(@login_time).getlocal)
  end

  def update
    ENV["UPDATE"] || "2017/01/19"
  end

  def is_watching_something(what)
    return !session[:currently_watching].nil? if what.nil?
    what = what.to_s
    return false if session[:currently_watching].nil?
    !session[:currently_watching][what].nil?
  end

  def current_episode
    return nil if session[:currently_watching].nil?
    @current_episode ||= Episode.find(session[:currently_watching]["episode"])
  end

  def current_admin_show_id
    return -1 unless logged_in? && current_user.is_admin?
    @current_show_id ||= session[:current_show_id]
    if @current_show_id.nil?
      shows = Show.all_published
      if !shows.blank?
        select_show = shows[0].id;
      else
        select_show = Show.first.nil? ? -1 : @select_show.id
      end
      @current_show_id = select_show
      current_admin_show_id = select_show
    end
    @current_show_id
  end

  def set_current_admin_show_id(id)
    p "Now: #{current_admin_show_id}"
    return false unless logged_in? && current_user.is_admin?
    @current_show_id = id
    session[:current_show_id] = id
    p "After: #{current_admin_show_id}"
  end

  def current_action(action=nil)
    @action ||= action
  end

  def current_controller(controller=nil)
    @controller ||= controller
  end

  def set_title(before: nil, after: nil, reset: true, home: false)
    @app_title = nil if reset
    if @app_title.nil?
      @app_title = "Private" if home == true
      @app_title = t('app.name') if home == false
    end
    unless before.nil?
      @app_title = "#{before} | #{@app_title}"
    end
    unless after.nil?
      @app_title << " | #{after}"
    end
    @app_title
  end

  def app_colour
    '#BE585C'
  end

  def google_search(show)
    "https://www.google.com/search?q=#{show.get_title} Anime"
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_token
    return nil unless logged_in?
    current_user.auth_token
  end

  def logged_in?
    if maintenance_activated?
      _logout
      false
    else
      !current_user.nil? && current_user.is_activated?
    end
  end

  def log_in(user)
    session[:user_id] = user.id
    session[:user_login_time] = Time.now
  end

  def log_out
    _logout if logged_in?
  end

  def comments_size_limit
    100
  end

  def comments_warning
    "You are posting as '#{current_user.username}'. Your name will not be displayed."
  end

  def is_maintenance_activated?
    ENV["TANOSHIMU_MAINTENANCE"] == "true"
  end

  def maintenance_activated?(user: nil)
    user = current_user || user
    if !user.nil? && is_maintenance_activated?
      !user.is_admin?
    else
      false
    end
  end

  private
  def _logout
    session.delete(:user_id)
    session.delete(:current_show_id)
  end

end
