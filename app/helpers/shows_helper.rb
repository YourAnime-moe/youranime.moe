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

  def sub_dub_rating_holder(show)
    return content_tag(:div) unless show.class == Show

    content_tag :div, class: 'sub-dub-holder justify-content-between' do
      show_sub_dub(show) +
      show_rating(show)
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

  def show_rating(show)
    return '' unless show.kind_of?(Show) && !show.ratings.empty?

    badge(type: 'info', content: show.rating)
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
    content_tag(:span)
  
    #content = content_tag(:span) do
    #  content_tag(:i, class: 'material-icons', style: 'font-size: 12px;') do
    #    'close'
    #  end + content_tag(:span) do
    #    " #{t('anime.episodes.broken')}"
    #  end
    #end
    #badge(type: 'danger', content: content)
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

    img_url = resource_url_for(show)

    rules ||= {}
    content_tag :div, class: 'overlay darken' do
      (top_badges(show) +
      image_for(show, id: show.id, onload: 'fadeIn(this)', class: "card-img-top descriptive #{'not-avail' if restricted?(show)} #{rules[:display]} #{'broken' if broken?(show)}") +
      sanitize(show_thumb_description(show)))
    end
  end

  def top_badges(show)
    content_tag :div, class: 'justify-content-between d-flex top-tags-holder' do
      sanitize(check_episode_available(show)) +
        sub_dub_rating_holder(show) +
        check_episode_cc(show)
    end
  end

  def seasons_tabs(show, admin: false)
    show_seasons = show.seasons.to_a.reject do |season|
      (check_admin?(admin) ? season.episodes : season.published_episodes).empty?
    end
    return '' if show_seasons.empty? && !check_admin?(admin)

    seasons_tabs = show_seasons.map do |season|
      content_tag :li, class: ('is-active' if season.number == 1) do
        content_tag :a, href: "#season-#{season.number}", data: {season: season.number.to_s} do
          season.name.presence || season.default_name
        end
      end
    end

    if admin
      seasons_tabs << content_tag(:li) do
        content_tag :a, href: '#new-season', data: {season: 'new'} do
          "Add new season"
        end
      end
    end

    content_tag :div, class: 'tabs is-boxed' do
      content_tag :ul do
        sanitize(seasons_tabs.join(''), attributes: %w(href data-season class))
      end
    end
  end

  def like_button(show, info: false)
    colour = show.liked_by?(current_user) ? 'success' : 'light'
    react_button(show, colour, 'thumb_up', reaction: :like, info: info)
  end

  def love_button(show, info: false)
    colour = show.liked_by?(current_user) ? 'pink' : 'light'
    react_button(show, colour, 'favorite', reaction: :love, info: info)
  end

  def dislike_button(show, info: false)
    colour = show.disliked_by?(current_user) ? 'danger' : 'light'
    react_button(show, colour, 'thumb_down', reaction: :dislike, info: info)
  end

  def react_button(show, colour, icon, reaction:, info: false)
    content_tag :button, id: reaction, class: "button #{'is-icon' unless info} is-#{colour}", reaction: reaction do
      content_tag :i, class: 'material-icons' do
        icon
      end
    end
  end

  def queue_button(show)
    show_added = current_user.has_show_in_main_queue?(show)
    colour = show_added ? 'success' : 'light'
    icon = show_added ? 'playlist_add_check' : 'playlist_add'

    content_tag :button, id: 'queue', class: "button is-icon is-#{colour}" do
      content_tag :i, class: 'material-icons' do
        icon
      end
    end
  end

  def queue_item(show)
    show_thumb(show)
  end

  private

  def valid_thumbable_class?(model)
    model.class == Show || model.class == Episode
  end

  def resource_url_for(model)
    return unless valid_thumbable_class?(model)
    return model if [Show, Episode].include?(model.class)
  end

  def check_admin?(admin)
    admin && current_user.staff_user.present?
  end
end
