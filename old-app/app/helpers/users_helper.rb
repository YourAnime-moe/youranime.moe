# frozen_string_literal: true

module UsersHelper
  def home_thumbnails_rules
    [
      { id: 0, class: '', display: '' },
      { id: 1, class: '', display: '' },
      { id: 2, class: '', display: '' },
      { id: 3, class: 'd-md-blocks', display: '' },
      { id: 4, class: 'd-none d-xl-block', display: '' },
      { id: 5, class: 'd-none d-xl-block', display: '' }
    ]
  end

  def thumb_class_for(model, index)
    rules = home_thumbnails_rules
    last_possible = rules.last[:id]
    rule = rules.select { |rule| rule[:id] == index }[0]
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
      actual: array
    }
  end

  def image_for(model, *args, **options)
    return nil unless [Episode, Show].include?(model.class)

    image = model.class == Episode ? model.thumbnail_url : model.banner_url
    image_tag(image, *args, **options)
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
end