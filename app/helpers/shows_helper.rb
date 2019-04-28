module ShowsHelper

  def show_tags(show)
    return '' if show.tags.blank?
    links = show.get_tags.map{|t| t.downcase.to_sym}.map do |tag|
      link_to(Utils.tags[tag], '#', class: 'btn tag')
    end
    content_tag(:div, class: 'tags-container') do
      links.join('').html_safe
    end
  end

  def sub_dub_holder(show)
    return content_tag(:div) unless show.class == Show
    content_tag :div, class: 'sub-dub-holder' do
      show_sub_dub(show)
    end
  end

  def check_episode_broken(episode)
    return '' if episode.class != Episode
    return content_tag(:span) if episode.video.attached?

    content_tag :div, class: 'sub-dub-holder' do
      broken_tag
    end
  end

  def check_episode_cc(episode)
    return '' if episode.class != Episode
    return '' unless episode.has_valid_subtitles?

    content_tag :div, class: 'captions-holder' do
      badge(type: 'info', content: 'captions')
    end
  end

  def show_sub_dub(show)
    return '' unless show.class == Show
    if show.subbed_and_dubbed?
      sub_tag + dub_tag
    elsif show.only_dubbed?
      dub_tag
    else
      sub_tag
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
    return '' unless valid_thumbable_class?(show)
    rules ||= {}
    return '' if show.nil? || hide_title
    content_tag :div, class: "hf-thumb-info description #{rules[:display]}", style: 'width: 95%' do
      content_tag :span, class: 'truncate' do
        show.get_title
      end
    end
  end

  def show_thumb(show, rules: nil)
    return '' unless valid_thumbable_class?(show)
    if show.class == Episode
      progress = show.progress(current_user).progress
    end
    rules ||= {}
    content_tag :div, class: "no-overflow #{rules[:class]}" do
      progress_bar = content_tag :div, class: 'progress', role: "progress" do
        content_tag(:div, class: 'progress-bar', style: "width: #{progress}%", role: 'progressbar', "aria-valuenow" => progress.to_i.to_s, "aria-valuemin" => "0", "aria-valuemax" => "100") do
        end
      end
      wrapper = content_tag :div, role: 'have-fun', style: 'display: none;' do
        content_tag :div, class: 'card shadow-sm borderless d-flex align-items-stretch' do
          content_tag :div, class: 'image-card-container focusable' do
            content_tag :div, class: 'holder' do
              show_thumb_body(show, rules: rules)
            end
          end
        end
      end
      wrapper + (progress_bar if show.class == Episode)
    end
  end

  def show_thumb_body(show, rules: nil)
    return '' unless valid_thumbable_class?(show)
    rules ||= {}
    content_tag :div, class: 'overlay darken' do
      (top_badges(show) +
      image_for(show, id: show.id, onload: 'fadeIn(this)', class: "card-img-top descriptive #{rules[:display]}") +
      show_thumb_description(show)).html_safe
    end
  end

  def top_badges(show)
    content_tag :div, class: 'justify-content-between d-flex top-tags-holder' do
      check_episode_broken(show).html_safe +
      sub_dub_holder(show) +
      check_episode_cc(show)
    end
  end

  private

  def valid_thumbable_class?(model)
    model.class == Show || model.class == Episode
  end

end
