module ShowsHelper

  def show_tags(show)
    return '' if show.tags.blank?
    links = show.tags.map{|t| t.downcase.to_sym}.map do |tag|
      link_to(Utils.tags[tag], '#', class: 'btn tag')
    end
    content_tag(:div, class: 'tags-container') do
      links.join('').html_safe
    end
  end

  def sub_dub_holder(show)
    return '' unless show.class == Show
    content_tag :div, class: 'sub-dub-holder' do
      show_sub_dub(show)
    end
  end

  def check_episode_broken(episode)
    return '' if episode.class != Show::Episode
    return '' if episode.video.attached?

    content_tag :div, class: 'sub-dub-holder' do
      broken_tag
    end
  end

  def show_sub_dub(show)
    return '' unless show.class == Show
    if show.only_subbed?
      sub_tag
    elsif show.only_dubbed?
      dub_tag
    else
      sub_tag + dub_tag
    end
  end

  def dub_tag
    badge(type: 'success', content: "dub")
  end

  def sub_tag
    badge(type: 'danger', content: "sub")
  end

  def broken_tag
    content = content_tag(:span) do
      content_tag(:i, class: 'material-icons', style: "font-size: 12px;") do
        "close"
      end + content_tag(:span) do
        " broken"
      end
    end
    badge(type: 'danger', content: content)
  end

  def badge(type: nil, content: nil)
    content_tag :span, class: "badge badge-#{type}" do
      content
    end
  end

  def show_thumb_description(show, hide_title: false, rules: nil)
    return '' if show.class != Show
    rules ||= {}
    return '' if show.nil? || hide_title
    content_tag :div, class: "hf-thumb-info description #{rules[:display]}", style: 'width: 95%' do
      content_tag :span, class: 'truncate' do
        show.get_title
      end
    end
  end

  def show_thumb(show, rules: nil)
    return '' if show.class != Show
    rules ||= {}
    content_tag :div, class: "no-overflow #{rules[:class]}" do
      content_tag :div, role: 'have-fun', style: 'display: none;' do
        content_tag :div, class: 'card shadow-sm borderless d-flex align-items-stretch' do
          content_tag :div, class: 'image-card-container focusable' do
            content_tag :div, class: 'holder' do
              show_thumb_body(show, rules: rules)
            end
          end
        end
      end
    end
  end

  def show_thumb_body(show, rules: nil)
    return '' if show.class != Show
    rules ||= {}
    content_tag :div, class: 'overlay darken' do
      sub_dub_holder(show) +
      check_episode_broken(show) +
      image_for(show, id: show.id, onload: 'fadeIn(this)', style: 'display: none;', class: "card-img-top descriptive #{rules[:display]}") +
      show_thumb_description(show)
    end
  end

end
