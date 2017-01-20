class AuthenticatedController < ApplicationController

    before_action {
        unless logged_in?
            redirect_to '/login'
        end
    }

end