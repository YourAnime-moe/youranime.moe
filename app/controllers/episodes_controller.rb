class EpisodesController < AuthenticatedController

  layout 'videos'

  def show
    shows_list = current_user.admin? ? Show.all : Show.published
    show = shows_list.find_by(id: params[:show_id])
    if show.nil?
      flash[:warning] = "Sorry but this show is not available at the moment."
      redirect_to shows_path
      return
    end
    @episode = show.episodes.find_by(id: params[:id])
    if @episode.nil?
      flash[:warning] = "Sorry, this episode is not available at the moment."
      redirect_to show_path(show)
      return
    end
    if current_user.google_user && @episode.restricted?
      flash[:warning] = "As a Google user, you are not permitted to watch this episode. Please contact the admins."
      redirect_to show_path(show)
      return
    end
    set_title before: t('anime.episodes.title', name: @episode.get_title), after: show.get_title
  end

  def update
    episode = Episode.find(params[:id])
    progress = episode_params[:progress].to_f
    success = episode.set_progress(current_user, progress)
    render json: {
      success: success,
      episode: episode,
      progress: progress
    }
  end

  private

  def episode_params
    params.require(:episode).permit(
      :progress
    )
  end

end
