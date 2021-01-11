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

  def show_info_holder(show)
    return content_tag(:div) unless show.class == Show

    content_tag(:div, class: 'sub-dub-holder justify-content-between') do
      show_type_badge(show) +
      show_airing_badge(show) +
      show_nsfw_badge(show) +
      show_rating(show)
    end
  end

  def check_episode_available(episode)
    return '' if episode.class != Episode

    if episode.unrestricted?
      if episode.video?
        content_tag(:span)
      else
        content_tag(:div, class: 'sub-dub-holder') do
          broken_tag
        end
      end
    elsif current_user.google?
      content_tag(:div, class: 'sub-dub-holder') do
        restricted_tag
      end
    else
      content_tag(:span)
    end
  end

  def check_episode_cc(episode)
    return '' if episode.class != Episode
    return '' unless episode.subtitles?

    return content_tag(:spam) if restricted?(episode)

    content_tag(:div, class: 'captions-holder') do
      badge(type: 'info', content: 'captions')
    end
  end

  def show_rating(show)
    return '' unless show.is_a?(Show) && !show.ratings.empty?

    badge(type: 'info', content: show.rating)
  end

  def can_display_airing_badge?(show)
    return false if !show.is_a?(Show) || show.is?(:music)

    show.air_complete? || show.coming_soon? || show.airing?
  end

  def show_nsfw_badge(show)
    return '' unless show.is_a?(Show) && show.nsfw?

    badge(type: 'danger', content: 'NSFW')
  end

  def show_airing_badge(show, force: false)
    return '' unless force || can_display_airing_badge?(show)

    badge(type: 'light', content: t("anime.shows.airing_status.#{show.status}"))
  end

  def show_type_badge(show)
    return '' unless show.class == Show

    bagde_for_show_type(show.show_type)
  end

  def bagde_for_show_type(show_type)
    if show_type == 'movie'
      badge(type: :info, content: t('anime.shows.movie'))
    elsif show_type == 'game'
      badge(type: :warning, content: t('anime.shows.game'))
    elsif show_type == 'music'
      badge(type: :danger, content: t('anime.shows.music'), light: true)
    elsif show_type == 'special'
      badge(type: :light, content: t('anime.shows.special'))
    elsif ['ONA', 'OVA'].include?(show_type)
      badge(type: :primary, content: t("anime.shows.#{show_type.downcase}"), light: true)
    else
      badge(type: :primary, content: t("anime.shows.#{show_type.downcase}"))
    end
  end

  def broken_tag
    content_tag(:span)

    # content = content_tag(:span) do
    #  content_tag(:i, class: 'material-icons', style: 'font-size: 12px;') do
    #    'close'
    #  end + content_tag(:span) do
    #    " #{t('anime.episodes.broken')}"
    #  end
    # end
    # badge(type: 'danger', content: content)
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

  def badge(type: nil, content: nil, light: false)
    content_tag(:span, class: "tag is-#{type} #{'is-light' if light}") do
      content
    end
  end

  def show_thumb_description(show, hide_title: false, rules: nil)
    return '' unless valid_thumbable_class?(show)

    rules ||= {}
    return '' if show.nil? || hide_title

    content_tag(:div, class: "hf-thumb-info description #{rules[:display]}", style: 'width: 95%') do
      content_tag(:span, class: 'truncate') do
        show.title
      end
    end
  end

  def show_skeleton
    content_tag(:div, class: 'columns is-tiny-gap no-margin shows') do
      (content_tag(:div, class: "column is-3") do
        show_skeleton_thumb
      end + content_tag(:div, class: "column is-3") do
        show_skeleton_thumb
      end + content_tag(:div, class: "column is-3") do
        show_skeleton_thumb
      end + content_tag(:div, class: "column is-3") do
        show_skeleton_thumb
      end)
    end
  end

  def show_skeleton_thumb
    content_tag(:div, class: "no-overflow") do
      content_tag(:div, role: 'skeleton') do
        content_tag(:div, class: 'card shadow-sm borderless d-flex align-items-stretch') do
          content_tag(:div, class: 'image-card-container focusable') do
            content_tag(:div, class: 'holder') do
              show_skeleton_thumb_body
            end
          end
        end
      end
    end
  end

  def show_thumb(show, rules: nil)
    return '' unless valid_thumbable_class?(show)

    # progress = (current_user.progress_for(show) if show.class == Episode) || 0
    progress = 0
    rules ||= {}
    content_tag(:div, class: "no-overflow #{rules[:class]}") do
      progress_bar = "<progress class='progress is-primary is-small' value='#{progress}' max='100'>3</progress>".html_safe
      sketelon = content_tag(:div, role: 'skeleton') do
        show_skeleton_thumb
      end
      wrapper = content_tag(:div, role: 'have-fun', style: 'display: none;') do
        content_tag(:div, class: 'card shadow-sm borderless d-flex align-items-stretch') do
          content_tag(:div, class: 'image-card-container focusable') do
            content_tag(:div, class: 'holder') do
              show_thumb_body(show, rules: rules)
            end
          end
        end
      end
      sketelon + wrapper + (progress_bar if show.class == Episode && progress.positive?)
    end
  end

  def show_skeleton_thumb_body
    content_tag(:div, class: 'overlay darken') do
      image_tag('/tanoshimu-sketelon.png')
    end
  end

  def show_thumb_body(show, rules: nil)
    return '' unless valid_thumbable_class?(show)

    img_url = resource_url_for(show)

    rules ||= {}
    content_tag(:div, class: 'overlay darken') do
      (top_badges(show) +
      image_for(show, id: show.id, onload: 'fadeIn(this)',
class: "card-img-top descriptive #{'not-avail' if restricted?(show)} #{rules[:display]} #{'broken' if broken?(show)}", style: 'height: 0;') +
      sanitize(show_thumb_description(show)))
    end
  end

  def top_badges(show)
    content_tag(:div, class: 'justify-content-between d-flex top-tags-holder') do
      sanitize(check_episode_available(show)) +
        show_info_holder(show) +
        check_episode_cc(show)
    end
  end

  def seasons_tabs(show, admin: false)
    show_seasons = show.seasons.to_a.reject do |season|
      (check_admin?(admin) ? season.episodes : season.published_episodes).empty?
    end
    return '' if show_seasons.empty? && !check_admin?(admin)

    seasons_tabs = show_seasons.map do |season|
      content_tag(:li, class: ('is-active' if season.number == 1)) do
        content_tag(:a, href: "#season-#{season.number}", data: { season: season.number.to_s }) do
          season.name.presence || season.default_name
        end
      end
    end

    if admin
      seasons_tabs << content_tag(:li) do
        content_tag(:a, href: '#new-season', data: { season: 'new' }) do
          "Add new season"
        end
      end
    end

    content_tag(:div, class: 'tabs is-boxed') do
      content_tag(:ul) do
        sanitize(seasons_tabs.join(''), attributes: %w(href data-season class))
      end
    end
  end

  def like_button(show, info: false)
    colour = show.liked_by?(current_user) ? 'success' : 'light'
    react_button(show, colour, 'thumb_up', reaction: :like, info: info, text: 'Like')
  end

  def love_button(show, info: false)
    colour = show.liked_by?(current_user) ? 'pink' : 'light'
    react_button(show, colour, 'favorite', reaction: :love, info: info)
  end

  def dislike_button(show, info: false)
    colour = show.disliked_by?(current_user) ? 'danger' : 'light'
    react_button(show, colour, 'thumb_down', reaction: :dislike, info: info)
  end

  def react_button(_show, colour, icon, reaction:, info: false, text: nil)
    return unless current_user.can_like?

    content_tag(:button, id: reaction, class: "button #{'is-icon' unless info} is-#{colour}", reaction: reaction) do
      content_tag(:i, class: 'material-icons', style: (text.present? && 'padding-right: 5px;')) do
        icon
      end + ((content_tag(:span) { text }) if text.present?).to_s
    end
  end

  def queue_button(show)
    show_added = current_user.has_show_in_main_queue?(show)
    colour = show_added ? 'success' : 'light'
    icon = show_added ? 'playlist_add_check' : 'playlist_add'

    content_tag(:button, id: 'queue', class: "button is-icon is-#{colour}") do
      content_tag(:i, class: 'material-icons') do
        icon
      end
    end
  end

  def admin_button(show)
    return unless current_user.can_manage?

    link_to(admin_show_path(show), class: 'button is-rounded is-warning', target: :_blank) do
      'View on Admin panel'
    end
  end

  def queue_item(show)
    show_thumb(show)
  end

  def show_other_title(show)
    show_title = if I18n.locale == :en
      { lang: 'Japanese', title: show.title_record.jp }
    else
      { lang: '英語', title: show.title_record.en }
    end

    content_tag(:div, class: 'selectable') do
      content_tag(:span, class: 'subtitle', style: 'color: #aaa') do
        show_title[:title]
      end
    end
  end

  def link_to_show_url(show_url)
    link_to(show_url.value, class: 'show-url-image', target: :_blank, title: t("anime.platforms.#{show_url.platform}")) do
      try_show_url_icon_for(show_url.platform, ['png', 'jpg'])
    end
  end

  def try_show_url_icon_for(platform, extensions)
    return unless platform.present?

    extensions.each do |ext|
      p("Image: #{ShowUrl.icon_asset_filename_for(platform, ext: ext)}")
      return image_tag(ShowUrl.icon_asset_filename_for(platform, ext: ext))
    rescue Sprockets::Rails::Helper::AssetNotFound
      next
    end
    p("nahh for #{platform}")
    nil
  end

  def link_info(show_url)
    url_type = show_url.url_type
    url = show_url.value

    if show_url.platform.present?
      return { name: t("anime.platforms.#{show_url.platform}"), colour: show_url.colour }
    end

    { name: 'Unknown', colour: '#000000' }
  end

  def sort_shows_by_tabs
    search_tab = if params[:query].present?
      content_tag(:li, class: active_class_for('search')) do
        content_tag(:span) do
          "Search for \"#{params[:query]}\""
        end
      end
    else
      content_tag(:div)
    end
    content_tag(:div, class: 'tabs padded-bottom') do
      content_tag(:ul) do
        search_tab +
        content_tag(:li, class: active_class_for('watch-online')) do
          link_to(t('anime.shows.watch-online'), shows_path(by: 'watch-online'))
        end +
          content_tag(:li, class: active_class_for('trending')) do
            link_to(t('anime.shows.trending'), shows_path(by: :trending))
          end +
          content_tag(:li, class: active_class_for(blank: true)) { link_to(t('anime.shows.view-all'), shows_path) } +
          content_tag(:li, class: active_class_for('coming-soon')) do
            link_to(t('anime.shows.coming-soon'), shows_path(by: 'coming-soon'))
          end +
          content_tag(:li, class: active_class_for('airing')) do
            link_to(t('anime.shows.airing-now'), shows_path(by: :airing))
          end +
          content_tag(:li, class: active_class_for('recent')) do
            link_to(t('anime.shows.recent'), shows_path(by: :recent))
          end
      end
    end
  end

  def popularity_colour(show)
    return unless show.popularity?

    if show.popularity < 48
      '#24c100' # dark-green
    elsif show.popularity < 100
      '#2df200' # green
    elsif show.popularity < 500
      '#89ff00' # light-green
    elsif show.popularity < 1000
      '#c9ff00' # yellow-green
    elsif show.popularity < 5000
      '#ffe700' # yellow
    elsif show.popularity < 10000
      '#FFA500' # orange
    elsif show.popularity < 15000
      '#ff6700' # red
    else
      '#ff0000'
    end
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
    admin && current_user.can_manage?
  end

  def active_class_for(value = nil, blank: false)
    condition = if blank
      params[:by].blank?
    elsif value.present?
      params[:by] == value.to_s
    end

    condition ? 'is-active' : ''
  end
end
