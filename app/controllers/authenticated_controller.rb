class AuthenticatedController < ApplicationController

    before_action {
        unless logged_in?
            redirect_to '/login'
        end

        if params['controller'] == 'shows'
            p "NO CACHE!!!"
            response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
            response.headers["Pragma"] = "no-cache"
            response.headers["Expires"] = "Fri, 01 Jan 1900 00:00:00 GMT"
        end
    }

end