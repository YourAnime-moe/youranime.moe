class ShowsController < AuthenticatedController

  include ShowsHelper

  def index
    set_title(before: t('anime.shows.view-all'))
    @shows = fetch_shows.paginate(page: params[:page])
    @shows_count = @shows.count
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

    Show.published
      .includes(:title_record, :ratings)
      .order("titles.#{I18n.locale}")
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
