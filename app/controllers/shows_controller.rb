# frozen_string_literal: true
class ShowsController < ApplicationController
  include ShowsHelper

  before_action :ensure_logged_in!, except: [:index, :show, :render_partial]

  def index
    shows_scope_info = shows_by

    fetch_shows = if params[:query].present? && logged_in?
      shows = Search.perform(search: params[:query], format: :shows)
      @title = t("anime.shows.search")
      @title_subtitle = t("anime.shows.search-result", count: shows.count)
      @search_results = true

      shows
    else
      if shows_scope_info[:platform]
        shows = shows_scope_info[:scope]
        @title = t("anime.platforms.#{params[:by]}")
        @title_subtitle = t("anime.shows.search-result", count: shows.count)
      else
        title_key = shows_scope_info[:title]
        @title = t("anime.shows.#{title_key}")
        @title_subtitle = t("anime.shows.#{title_key}-what", **titles_options)
      end

      shows_scope_info[:scope]
    end

    @shows = fetch_shows.paginate(page: params[:page])
    @shows_count = @shows.count

    set_title(before: @title)
  end

  def show
    if (@show = show_by_slug(params[:slug])).present?
      Shows::Kitsu::Get.perform(kitsu_id: @show.reference_id) if @show.kitsu?

      if navigatable?(@show)
        set_title(before: @show.title)
        @episodes = episodes_map(@show)
        @additional_main_class = 'no-margin no-padding'
      else
        flash[:warning] = "This show is not available yet. Check back later!"
        redirect_to(shows_path)
      end
    elsif (show = Show.find_by(id: params[:slug]))
      redirect_to(show_path(show.title_record.roman))
    else
      flash[:warning] = "This show does not exist. Please try again later."
      redirect_to(shows_path)
    end
  end

  def action_buttons
    if (@show = show_by_slug(params[:show_slug])).present? || current_user.can_like?
      render(template: 'shows/partial/action_buttons', layout: false)
    else
      render(text: 'not found', status: 404)
    end
  end

  def search_partial
    @search_result = Search.perform(search: params[:query], limit: 10)

    render(template: 'shows/partial/search', layout: false)
  end

  def react
    if (show = show_by_slug(params[:show_slug])) && current_user.can_like?
      result = Shows::UpdateReaction.perform(show: show, user: current_user, reaction: params[:reaction])
      render(json: { success: true, result: result })
    else
      render(json: { error: true }, status: 422)
    end
  end

  def queue
    if (show = show_by_slug(params[:show_slug]))
      result = if current_user.has_show_in_main_queue?(show)
        current_user.remove_show_from_main_queue(show) && :removed
      else
        current_user.add_show_to_main_queue(show) && :added
      end
      render(json: { success: true, result: result })
    else
      render(json: { error: true }, status: 422)
    end
  end

  def render_partial
    @show = show_by_slug!(params[:show_slug])

    render(template: "/shows/partial/#{params[:partial_name]}", layout: false)
  end

  private

  def shows_by
    return { scope: Show.trending, title: 'trending' } if params[:by] == 'trending'
    return { scope: Show.as_music, title: 'music' } if params[:by] == 'music'
    return { scope: Show.recent, title: 'recent' } if params[:by] == 'recent'
    return { scope: Show.airing, title: 'airing-now' } if params[:by] == 'airing'
    return { scope: Show.coming_soon, title: 'coming-soon' } if params[:by] == 'coming-soon'
    return { scope: Show.with_links, title: 'with-links' } if params[:by] == 'watch-online'

    if ShowUrl.popular_platforms.include?(params[:by])
      return { scope: Show.where_platform(params[:by]), platform: true }
    end

    { scope: Show.ordered, title: 'view-all' }
  end

  def titles_options
    return {} unless ['coming-soon', 'airing'].include?(params[:by])

    return { season: Config.current_season[:localized] } if params[:by] == 'airing'
    return { season: Config.next_season[:localized] } if params[:by] == 'coming-soon'

    {}
  end

  def show_by_slug(slug)
    show_by_slug!(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def show_by_slug!(slug)
    show = Show.find_by_slug!(slug)
    # Shows::Kitsu::Get.perform(kitsu_id: show.reference_id) if show.kitsu?

    show
  end

  def navigatable?(show)
    if logged_in?
      show.published? || params[:as_admin] == 'true' && current_user.can_manage?
    else
      show.published?
    end
  end

  def episodes_map(show)
    show.seasons.includes(:episodes).map do |season|
      {
        season: season.number,
        episodes: season.published_episodes.each_slice(3).to_a,
      }
    end
  end
end
