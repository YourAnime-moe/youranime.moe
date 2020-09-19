module ApplicationHelper
  def current_user
    if Config.demo? && (demo_user = User.demo)
      return @current_user = demo_user
    end
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

  def set_title(before: nil, after: nil)
    @app_title = t('app.name') if @app_title.nil?
    @app_title = "#{before} | #{@app_title}" unless before.nil?
    @app_title << " | #{after}" unless after.nil?
    @app_title
  end

  def episode_path(episode, *_args, **options)
    path = "/shows/#{episode.show.slug}/episodes/#{episode.number}"
    path << '.' << options[:format].to_s if options[:format]
    path
  end

  def hf_header(title, subtitle: nil, link_title: nil, link: nil)
    subtitle_markup = content_tag(:div, class: 'subtitle') do
      subtitle
    end
    title_markup = content_tag(:div, class: 'tanoshimu-list-title') do
      content_tag(:span) { title } + subtitle_markup
    end
    link_markup = link_to(link_title, link, class: 'button is-rounded is-dark')
    content_tag(:div, class: 'justified w-100') do
      title_markup + link_markup
    end
  end

  def text_color(from:)
    data = from.match(%r{([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})})
    return unless data.size >= 4

    r, g, b = [data[1], data[2], data[3]].map(&:hex)
    brigthness = ((r*299)+(g*587)+(b*114))/1000

    brigthness > 125 ? '#000' : '#fff'
  end

  private

  def _logout
    user = current_user
    user.delete_auth_token!
    session.delete(:user_id)
    session.delete(:current_show_id)
    return if Config.slack_client.nil?

    Config.slack_client.chat_postMessage(channel: '#sign-ins', text: "[SIGN OUT] User #{user.username}-#{user.id} at #{Time.zone.now}.")
  end
end
