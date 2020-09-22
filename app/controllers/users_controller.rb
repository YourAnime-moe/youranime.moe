# frozen_string_literal: true

class UsersController < AuthenticatedController
  include UsersHelper

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
end
