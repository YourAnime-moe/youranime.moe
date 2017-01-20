module ApplicationHelper

    def app_title
        @app_title
    end

    def set_title(before: nil, after: nil, reset: true, home: false)
        @app_title = nil if reset
        if @app_title.nil?
            @app_title = "Private" if home == true
            @app_title = "Have fun" if home == false
        end
        unless before.nil?
            @app_title = "#{before} | #{@app_title}"
        end
        unless after.nil?
            @app_title << " | #{after}"
        end
        @app_title
    end

    def app_colour
        '#e5d8cc'
    end

    def google_search(show)
        "https://www.google.com/search?q=#{show.get_title} Anime"
    end

    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end

    def logged_in?
        !current_user.nil?
    end

    def log_in(user)
        session[:user_id] = user.id
        session[:user_login_time] = Time.now
    end

    def log_out
        _logout if logged_in?
    end

    private
        def _logout
            session.delete(:user_id)
        end

end
