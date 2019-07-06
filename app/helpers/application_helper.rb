# frozen_string_literal: false

module ApplicationHelper
  def app_colour
    '#BE585C'
  end

  def episode_path(episode, *_args, **options)
    path = "/shows/#{episode.show.id}/episodes/#{episode.id}"
    path << '.' << options[:format].to_s if options[:format]
    path
  end

  def svg_tag(icon, css_class: '')
    content_tag(:svg, class: "icon icon_#{icon} #{css_class}") do
      content_tag(:use, nil, 'xlink:href' => "#icon_#{icon}")
    end
  end

  def main_navigation_icon(default_icon)
    case current_state
    when 'shows::show'
      'arrow_back'
    else
      default_icon
    end
  end

  def backdrop_url
    asset_path("backdrop-#{I18n.locale}.png")
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
