class ShowsController < AuthenticatedController

  include ShowsHelper

  def index
    title_key = if params[:by] == 'trending'
      'trending'
    elsif params[:by] == 'recent'
      'recent'
    else
      'view-all'
    end
    @title = t("anime.shows.#{title_key}")
    @title_subtitle = t("anime.shows.#{title_key}-what")

    @shows = fetch_shows.paginate(page: params[:page])
    @shows_count = @shows.count

    set_title(before: @title)
  end

  def show
    if (@show = show_by_slug(params[:slug])).present?
      if navigatable?(@show)
        set_title(:before => @show.title)
        @episodes = episodes_map(@show)
        @additional_main_class = 'no-margin no-padding'
      else
        flash[:warning] = "This show is not available yet. Check back later!"
        redirect_to shows_path
      end
    elsif (show = Show.find_by(id: params[:slug]))
      redirect_to(show_path(show.title_record.roman))
    else
      flash[:warning] = "This show does not exist. Please try again later."
      redirect_to shows_path
    end
  end

  def search
    results = params[:query].present? && params[:query].size >= 3 ? Show.search(params[:query]) : []

    render json: results
  end

  def action_buttons
    if (@show = show_by_slug(params[:show_slug])).present?
      render template: 'shows/partial/action_buttons', layout: false
    else
      render text: 'not found', status: 404
    end
  end

  def search_partial

  end

  def react
    if (show = show_by_slug(params[:show_slug]))
      result = Shows::UpdateReaction.perform(show: show, user: current_user, reaction: params[:reaction])
      render json: { success: true, result: result }
    else
      render json: { error: true }, status: 422
    end
  end
  
  def queue
    if (show = show_by_slug(params[:show_slug]))
      result = if current_user.has_show_in_main_queue?(show)
        current_user.remove_show_from_main_queue(show) && :removed
      else
        current_user.add_show_to_main_queue(show) && :added
      end
      render json: { success: true, result: result }
    else
      render json: { error: true }, status: 422
    end
  end

  private

  def fetch_shows
    return Show.search(params[:query]) if params[:query].present?

    base_shows_scope = if params[:by] == 'trending'
      Show.trending
    elsif params[:by] == 'recent'
      Show.recent
    else
      Show.published.order("titles.#{I18n.locale}")
    end
    
    base_shows_scope
      .includes(:title_record, :ratings)
  end

  def show_by_slug(slug)
    (title = Title.find_by(roman: slug)) && title.record
  end

  def navigatable?(show)
    show.published? || params[:as_admin] == 'true' && current_user.staff_user.present?
  end

  def episodes_map(show)
    show.seasons.includes(:episodes).map do |season| 
      {
        season: season.number,
        episodes: season.published_episodes.each_slice(3).to_a
      }
    end
  end

end
