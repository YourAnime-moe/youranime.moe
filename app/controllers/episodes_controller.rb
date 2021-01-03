# frozen_string_literal: true
class EpisodesController < AuthenticatedController
  layout 'videos'

  before_action :ensure_show_available!, only: [:show, :update]
  before_action :ensure_episode_available!, only: [:show, :update]
  before_action :check_user_restrictions!, only: [:show, :update]

  def show
    set_title(before: t('anime.episodes.title', name: @episode.title), after: @show.title)
  end

  def update
    progress = episode_params[:progress].to_f
    success = @episode.set_progress(current_user, progress)
    render(json: {
      success: success,
      episode: @episode,
      progress: progress,
    })
  end

  private

  def episode_params
    params.require(:episode).permit(
      :progress
    )
  end

  def shows
    @shows ||= current_user.admin? ? Show.all : Show.published
  end

  def ensure_show_available!
    @show = shows.find_by_slug(params[:show_slug])
    if @show.nil?
      flash[:warning] = "Sorry but this show is not available at the moment."
      redirect_to(shows_path)
    end
  end

  def ensure_episode_available!
    @episode = @show.published_episodes.where(number: params[:id]).first
    if @episode.nil?
      flash[:warning] = "Sorry, this episode is not available at the moment."
      redirect_to(show_path(@show))
    end
  end

  def check_user_restrictions!
    if current_user.google? && @episode.restricted?
      flash[:warning] = "As a Google user, you are not permitted to watch this episode. Please contact the admins."
      redirect_to(show_path(@show))
    end
  end
end
