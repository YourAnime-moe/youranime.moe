# frozen_string_literal: true

class ShowThumbnailComponent < ViewComponent::Base
  def initialize(show:)
    @show = show
  end

  def title
    @show.title
  end

  def resource_url
    @show
  end

  def show_type
    @show.show_type
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
