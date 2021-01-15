# frozen_string_literal: true
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

  def logged_in_as_admin?
    logged_in? && current_user.can_manage?
  end

  def log_in(user)
    session[:user_id] = user.id
    session[:user_login_time] = Time.zone.now
    Rails.logger.info("User #{user.name} is now logged")
  end

  def log_out
    _logout if logged_in?
  end

  def viewing_as_admin?
    Config.viewing_as_admin_from?(request)
  end

  def header_appearance
    if viewing_as_admin?
      'admin'
    else
      'is-dark'
    end
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
    title_parts = []
    title_parts << before if before.present?
    title_parts << t('app.name')
    title_parts << after if after.present?

    @app_title = title_parts.join(' ~ ')
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
    link_markup = link_to(link_title, link, class: 'button is-rounded is-dark') if link_title && link
    content_tag(:div, class: 'justified w-100') do
      title_markup + link_markup.to_s
    end
  end

  def text_color(from:)
    data = from.match(/([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})/)
    return unless data.size >= 4

    r, g, b = [data[1], data[2], data[3]].map(&:hex)
    brigthness = ((r * 299) + (g * 587) + (b * 114)) / 1000

    brigthness > 125 ? '#000' : '#fff'
  end

  def current_platform
    name = (ShowUrl.where(url_type: params[:by]).any? && params[:by]).presence
    return unless name.present?

    Platform.find_by(name: name)
  end

  def login_then_redirect_path
    login_path(next: NextLinkFinder.perform(path: request.fullpath))
  end

  def logout_then_redirect_path
    logout_path(next: NextLinkFinder.perform(path: request.fullpath))
  end

  def airing_in(starts_on)
    difference = (starts_on - current_time.to_date).to_i
    difference_this_week = difference.abs % 7
    return { title: 'time.airing.today.title', content: 'time.airing.today.content' } if difference_this_week == 0

    past = difference < 0
    if difference_this_week == 1
      return { title: 'time.airing.yesterday.title', content: 'time.airing.yesterday.content' } if past

      return { title: 'time.airing.tomorrow.title', content: 'time.airing.tomorrow.content' }
    end

    options = if past
      { title: 'time.airing.past.title', content: 'time.airing.past.content' }
    else
      { title: 'time.airing.future.title', content: 'time.airing.future.content' }
    end

    options.merge({ past: past, count: difference_this_week })
  end

  def request_id
    request.uuid
  end

  def render_breadcrumbs
    return unless current_breadcrumbs.present?

    render(BreadcrumbsComponent.new(crumbs: current_breadcrumbs, active: @active_crumb))
  end

  def current_breadcrumbs
    @current_breadcrumbs ||= []
  end

  def breadcrumbs(active, *crumbs)
    @active_crumb = active
    crumbs |= [active]

    link_builder = ['']
    @current_breadcrumbs = crumbs.map do |crumb|
      if crumb == :home
        {
          link: '/',
          key: :home,
          name: t('breadcrumbs.names.home'),
        }
      else
        link_builder << crumb
        {
          link: link_builder.join('/'),
          key: crumb.try(:name) || crumb,
          name: crumb.try(:title) || t("breadcrumbs.names.#{crumb}"),
        }
      end
    end
  end

  def browser_timezone
    @browser_timezone ||= (begin
      ActiveSupport::TimeZone[-cookies[:tz].to_i.minutes]
    end if cookies[:tz].present?) || cookies[:timezone].presence
  end

  def current_time
    Time.current
  end

  private

  def _logout
    user = current_user
    user.delete_auth_token!
    session.delete(:user_id)
    session.delete(:current_show_id)
    return if Config.slack_client.nil?

    Config.slack_client.chat_postMessage(channel: '#sign-ins',
text: "[SIGN OUT] User #{user.username}-#{user.id} at #{Time.zone.now}.")
  end
end
