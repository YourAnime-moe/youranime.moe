# frozen_string_literal: true

module ShowsHelper
  def show_tags(show)
    return '' if show.tags.blank?

    links = show.tags.pluck(:value).map { |t| t.downcase.to_sym }.map do |tag|
      tag = Utils.tags[tag]
      next if tag.blank?

      content_tag(:span, class: 'button tag is-rounded is-dark') do
        tag
      end
    end
    content_tag(:div, class: 'tags-container') do
      sanitize(links.join(''))
    end
  end

  def sub_dub_holder(show)
    return content_tag(:div) unless show.class == Show

    content_tag :div, class: 'sub-dub-holder' do
      show_sub_dub(show)
    end
  end

  def check_episode_available(episode)
    return '' if episode.class != Episode

    if episode.unrestricted?
      if episode.video?
        content_tag(:span)
      else
        content_tag :div, class: 'sub-dub-holder' do
          broken_tag
        end
      end
    else
      if current_user.google?
        content_tag :div, class: 'sub-dub-holder' do
          restricted_tag
        end
      else
        content_tag(:span)
      end
    end
  end

  def check_episode_cc(episode)
    return '' if episode.class != Episode
    return '' unless episode.subtitles?

    return content_tag(:spam) if restricted?(episode)

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
    badge(type: 'warning', content: t('anime.shows.dub'))
  end

  def sub_tag
    badge(type: 'primary', content: t('anime.shows.sub'))
  end

  def broken_tag
    content = content_tag(:span) do
      content_tag(:i, class: 'material-icons', style: 'font-size: 12px;') do
        'close'
      end + content_tag(:span) do
        " #{t('anime.episodes.broken')}"
      end
    end
    badge(type: 'danger', content: content)
  end

  def restricted_tag
    content = content_tag(:span) do
      content_tag(:i, class: 'material-icons', style: 'font-size: 12px;') do
        'close'
      end + content_tag(:span) do
        " #{t('anime.episodes.not-available')}"
      end
    end
    badge(type: 'danger', content: content)
  end

  def badge(type: nil, content: nil)
    content_tag :span, class: "tag is-#{type}" do
      content
    end
  end

  def show_thumb_description(show, hide_title: false, rules: nil)
    return '' unless valid_thumbable_class?(show)

    rules ||= {}
    return '' if show.nil? || hide_title

    content_tag :div, class: "hf-thumb-info description #{rules[:display]}", style: 'width: 95%' do
      content_tag :span, class: 'truncate' do
        show.title
      end
    end
  end

  def show_thumb(show, rules: nil)
    return '' unless valid_thumbable_class?(show)

    # progress = (current_user.progress_for(show) if show.class == Episode) || 0
    progress = 0
    rules ||= {}
    content_tag :div, class: "no-overflow #{rules[:class]}" do
      progress_bar = "<progress class='progress is-primary is-small' value='#{progress}' max='100'>3</progress>".html_safe
      wrapper = content_tag :div, role: 'have-fun', style: 'display: none;' do
        content_tag :div, class: 'card shadow-sm borderless d-flex align-items-stretch' do
          content_tag :div, class: 'image-card-container focusable' do
            content_tag :div, class: 'holder' do
              show_thumb_body(show, rules: rules)
            end
          end
        end
      end
      wrapper + (progress_bar if show.class == Episode && progress.positive?)
    end
  end

  def show_thumb_body(show, rules: nil)
    return '' unless valid_thumbable_class?(show)

    rules ||= {}
    content_tag :div, class: 'overlay darken' do
      (top_badges(show) +
      image_for(show, id: show.id, onload: 'fadeIn(this)', class: "card-img-top descriptive #{'not-avail' if restricted?(show)} #{rules[:display]}") +
      sanitize(show_thumb_description(show)))
    end
  end

  def top_badges(show)
    content_tag :div, class: 'justify-content-between d-flex top-tags-holder' do
      sanitize(check_episode_available(show)) +
        sub_dub_holder(show) +
        check_episode_cc(show)
    end
  end

  def seasons_tabs(show)
    show_seasons = show.seasons.to_a.reject { |season| season.episodes.empty? }
    return '' if show_seasons.empty?

    seasons_tag = show_seasons.map do |season|
      content_tag :li, class: ('is-active' if season.number == 1) do
        content_tag :a, href: "#season-#{season.number}", data: {season: season.number.to_s} do
          "Season #{season.number}"
        end
      end
    end.join('')

    content_tag :div, class: 'tabs is-boxed has-text-light' do
      content_tag :ul do
        sanitize(seasons_tag, attributes: %w(href data-season class))
      end
    end
  end

  private

  def valid_thumbable_class?(model)
    model.class == Show || model.class == Episode
  end
end
