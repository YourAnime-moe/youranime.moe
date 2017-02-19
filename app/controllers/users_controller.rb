class UsersController < AuthenticatedController

    def home
        if params[:username] != current_user.username
            redirect_to "/users/#{current_user.username}"
        end
        set_title(before: "Welcome, #{current_user.get_name}")
        @shows = Show.lastest(current_user)
        @episodes = current_user.get_latest_episodes(limit: 4)
    end

    def short_settings
        redirect_to '/users/settings'
    end

    def settings
        set_title(before: 'Your settings')
    end

    def news
        set_title before: "Application News", after: "What's up?"
    end

    def update
        id = params[:id]
        begin
            user = User.find(id)
            if params[:user_settings]
                if user.update_settings(settings_params)
                    flash[:success] = "Update successful!"
                else
                    flash[:danger] = "Sorry, we can't seem to be able to update \"#{user.get_name}\"."
                end
            else
                if user.admin != user_params[:admin] and current_user.id == id
                    flash[:danger] = "Sorry, you can't update your previledges. Another administrator must do it for you."
                    return
                end
                if user.update_attributes(user_params)
                    flash[:success] = "Update successful!"
                    p user.settings
                else
                    flash[:danger] = "Sorry, we can't seem to be able to update \"#{user.get_name}\"."
                end
            end
        rescue AppError => e
            flash[:danger] = AppError.find(e.code)
        #rescue Exception => e
            #p e
            #flash[:danger] = "There was an internal error while trying to update this user."
        end
        redirect_to '/users/settings'
    end

    private
        def user_params
            params.require(:user).permit(
                :username,
                :name,
                :admin,
                :password,
                :password_confirmation
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
