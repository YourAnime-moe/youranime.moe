# frozen_string_literal: true

module UsersHelper
  def image_for(model, *args, **options)
    return nil unless [Episode, Show].include?(model.class)

    image_tag(fetch_image(model), *args, **options)
  end

  def user_emoji
    emoji = if Config.demo?
      'signal_cellular_off'
    elsif current_user.can_manage?
      'admin_panel_settings'
    elsif current_user.oauth?
      'link'
    elsif current_user.limited?
      'signal_cellular_null'
    else
      'signal_cellular_4_bar'
    end

    content_tag(:span) do
      content_tag(:i, class: 'material-icons', style: 'font-size: 18px') do
        emoji
      end
    end
  end

  private

  def fetch_image(model)
    return model.thumbnail_url if model.is_a?(Episode)

    # model.banner.attached? ? model.banner : model.banner_url
    model.poster
  end
end
