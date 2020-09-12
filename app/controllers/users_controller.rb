# frozen_string_literal: true

class UsersController < AuthenticatedController
  include UsersHelper

  # Home page
  def home
    set_title(before: t('user.welcome', user: current_user.name))
    episodes = Episode.published.includes(season: :show)

    ids = recent_shows_ids.uniq[0..(episodes.size.positive? ? 7 : 11)]
    @recent_shows = Show.published.includes(:title_record).order('created_at desc').where(id: ids).limit(8)
    @main_queue = current_user.main_queue.shows.limit(4)
    @trending = Show.trending.includes(:title_record).limit(8)
    @episodes = force_array_to(6, episodes)
    @recommendations = Shows::Recommend.perform(user: current_user, limit: 8)
  end

  # Going to settings
  def settings
    @episodes = current_user.currently_watching
    @episodes_size = @episodes.size
    @episodes = @episodes[0..10]
    set_title(before: t('header.settings'))
  end

  # Update the user
  def update
    id = params[:id]
    user = User.find(id)
    # if params[:user_settings]
    #   if user.update_settings(settings_params)
    #     flash[:success] = 'Update successful!'
    #   else
    #     flash[:danger] = "Sorry, we can't seem to be able to update \"#{user.name}\"."
    #   end
    # else
    if (user.admin != user_params[:admin]) && (current_user.id == id)
      flash[:danger] = "Sorry, you can't update your previledges. Another administrator must do it for you."
      return
    end
    if user.update(user_params)
      user.thumbnail.attach(params[:avatar]) if params[:avatar].class == ActionDispatch::Http::UploadedFile
      flash[:success] = 'Update successful!'
    else
      flash[:danger] = "Sorry, we can't seem to be able to update \"#{user.name}\"."
    end
    # end
    redirect_to '/users/settings'
  end

  def short_settings
    redirect_to '/users/settings'
  end

  private

  def user_params
    params.require(:user).permit(
      :username,
      :name,
      :admin,
      :password,
      :password_confirmation,
      :avatar
    )
  end

  def settings_params
    params.require(:user_settings).permit(
      :watch_anime,
      :last_episode,
      :episode_tracking,
      :recommendations,
      :images
    )
  end

  def home_shows
    shows = Show.recent.limit(100)
    return shows if shows.any?

    Show.published
  end

  def recent_shows_ids
    home_shows.map(&:id)
  end
end
