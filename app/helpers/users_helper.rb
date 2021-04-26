# frozen_string_literal: true

module UsersHelper
  def home_thumbnails_rules
    [
      { id: 0, class: '', display: '' },
      { id: 1, class: '', display: '' },
      { id: 2, class: '', display: '' },
      { id: 3, class: 'd-md-blocks', display: '' },
      { id: 4, class: 'd-none d-xl-block', display: '' },
      { id: 5, class: 'd-none d-xl-block', display: '' },
    ]
  end

  def thumb_class_for(model, index)
    rules = home_thumbnails_rules
    rule = rules.select { |r| r[:id] == index }[0]
    rule[:display] = 'd-none' if model.nil?
    rule
  end

  def force_array_to(size, array)
    return nil if array.nil? || !array.respond_to?(:size)
    return { cut: array, actual: array } if size <= 0

    current_size = array.size
    return { cut: array[0, size], actual: array } if current_size >= size

    {
      cut: array + ([nil] * (size - current_size)),
      actual: array,
    }
  end

  def image_for(model, *args, **options)
    return nil unless [Episode, Show].include?(model.class)

    image_tag(fetch_image(model), *args, **options)
  end

  def avatar_tag(size: 200, **options)
    return nil unless logged_in?

    if current_user.avatar.attached?
      image_tag(current_user.avatar.variant(resize_to_limit: [size, size]), **options)
    else
      url = "https://api.adorable.io/avatars/#{size}/#{current_user.username}.png"
      image_tag(url, alt: current_user.name, size: size, **options)
    end
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
