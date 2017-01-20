class UsersController < AuthenticatedController

    def home
        if params[:username] != current_user.username
            redirect_to "/users/#{current_user.username}"
        end
        set_title(before: "Welcome, #{current_user.get_name}")
        @shows = Show.lastest
    end

    def short_settings
        redirect_to '/users/settings'
    end

    def settings
        
    end

end
