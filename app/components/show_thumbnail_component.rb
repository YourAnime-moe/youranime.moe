# frozen_string_literal: true

class ShowThumbnailComponent < ViewComponent::Base
  def initialize(show:, focus_platform: nil)
    super
    @show = show
    @focus_platform = focus_platform
  end

  def title
    @show.title
  end

  def resource_url
    @show
  end

  def show_type
    @show.show_category
  end

  def badges
    options = []

    options << badge_options
    options << { type: :light, content: t("anime.shows.airing_status.#{@show.status}") } unless @show.air_complete?

    if @focus_platform
      platform_colour = ShowUrl.colour_for(@focus_platform)
      options << { background: platform_colour, colour: Utils.text_color(from: platform_colour), content: t("anime.platforms.#{@focus_platform}") }

      links_scope = @show.links.unless(url_type: @focus_platform)
      options << { type: :link, content: "+#{links_scope.count}" } if links_scope.any?
    elsif @show.links.count == 1
      link = @show.links.first
      options << { background: link.colour, colour: Utils.text_color(from: link.colour), content: t("anime.platforms.exclusively", on: t("anime.platforms.#{link.platform}")) }
    elsif @show.links.count > 1
      options << { type: :link, content: t("anime.platforms.streamable", count: @show.links.count) }
    end

    options
  end

  def badge_options
    options = {}

    if show_type == 'movie'
      options.merge!({ type: :info, content: t('anime.shows.movie') })
    elsif show_type == 'game'
      options.merge!({ type: :warning, content: t('anime.shows.game') })
    elsif show_type == 'music'
      options.merge!({ type: :danger, content: t('anime.shows.music'), light: true })
    elsif show_type == 'special'
      options.merge!({ type: :light, content: t('anime.shows.special') })
    elsif ['ONA', 'OVA'].include?(show_type)
      options.merge!({ type: :primary, content: t("anime.shows.#{show_type.downcase}"), light: true })
    else
      options.merge!({ type: :primary, content: t("anime.shows.#{show_type.downcase}") })
    end

    options
  end

  def can_display_airing_badge?
    !@show.is?(:music)
  end
end
