# frozen_string_literal: true

class ShowThumbnailComponent < ViewComponent::Base
  include ActionView::Helpers::DateHelper

  def initialize(show:, focus_platform: nil)
    super
    @show = if show.is_a?(ShowsQueueRelation)
      @queue_item = show
      show.show
    else
      show
    end
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
    options << { type: :light, text: t("anime.shows.airing_status.#{@show.status}") } unless @show.air_complete?

    if @queue_item.present?
      options << {
        type: :warning,
        text: queue_item_added_date_or_ago,
      }
    end

    if @focus_platform
      platform_colour = @focus_platform.colour
      options << {
        background: platform_colour,
        colour: Utils.text_color(from: platform_colour),
        text: t("anime.platforms.#{@focus_platform.name}"),
      }

      links_scope = @show.links.unless(url_type: @focus_platform.name)
      options << {
        type: :link,
        text: "+#{links_scope.count}",
      } if links_scope.any?
    elsif @show.links.count == 1
      link = @show.links.first
      options << {
        background: link.colour,
        colour: Utils.text_color(from: link.colour),
        text: t("anime.platforms.exclusively",
          on: t("anime.platforms.#{link.platform}")),
      }
    elsif @show.links.count > 1
      options << {
        type: :link,
        text: t("anime.platforms.streamable",
          count: @show.links.count),
      }
    end

    options
  end

  def badge_options
    options = {}

    if show_type == 'movie'
      options.merge!({ type: :info, text: t('anime.shows.movie') })
    elsif show_type == 'game'
      options.merge!({ type: :warning, text: t('anime.shows.game') })
    elsif show_type == 'music'
      options.merge!({ type: :danger, text: t('anime.shows.music'), light: true })
    elsif show_type == 'special'
      options.merge!({ type: :light, text: t('anime.shows.special') })
    elsif ['ONA', 'OVA'].include?(show_type)
      options.merge!({ type: :primary, text: t("anime.shows.#{show_type.downcase}"), light: true })
    else
      options.merge!({ type: :primary, text: t("anime.shows.#{show_type.downcase}") })
    end

    options
  end

  def can_display_airing_badge?
    !@show.is?(:music)
  end

  private

  def queue_item_added_date_or_ago
    return unless @queue_item.present?

    date = @queue_item.created_at

    if (Time.current - date) < 24 * 60 * 60
      t('anime.queue.added-ago', time_ago: time_ago_in_words(date))
    elsif (Time.current - date) < 48 * 60 * 60
      t('anime.queue.added-yesterday')
    else
      t('anime.queue.added-on', date: date.strftime(
        t('time.date.simple-format'),
      ))
    end
  end
end
