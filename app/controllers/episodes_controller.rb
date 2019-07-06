# frozen_string_literal: true

class EpisodesController < AuthenticatedController
  layout 'videos'

  before_action :ensure_show_is_available!, only: %i[show update]
  before_action :ensure_episode_is_available!, only: %i[show update]
  before_action :ensure_episode_is_not_restricted!, only: %i[show update]

  def show
    set_title(
      before: t('anime.episodes.title', name: @episode.title),
      after: show_for_episode.title
    )
  end

  def update
    episode = Episode.find(params[:id])
    progress = episode_params[:progress]
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

  def ensure_show_is_available!
    return unless show_for_episode.nil?

    flash[:warning] = 'Sorry but this show is not available at the moment.'
    redirect_to shows_path
  end

  def ensure_episode_is_available!
    @episode = show_for_episode.episodes.find_by(id: params[:id])
    return unless @episode.nil?

    flash[:warning] = 'Sorry, this episode is not available at the moment.'
    redirect_to show_path(show_for_episode)
  end

  def ensure_episode_is_not_restricted!
    return unless current_user.google_user && @episode.restricted?

    flash[:warning] = 'As a Google user, you are not permitted to watch this episode. Please contact the admins.'
    redirect_to show_path(show_for_episode)
  end

  def shows_list
    current_user.admin? ? Show.all : Show.published
  end

  def show_for_episode
    @show_for_episode ||= shows_list.find_by(id: params[:show_id])
  end
end
