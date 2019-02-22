class AuthenticatedController < ApplicationController

  include EpisodesHelper

  before_action {
    unless logged_in?
      if current_action && current_controller
        url = "/login?"
        if @par
          parameters = ""
          first = true
          @par.each do |k, v|
            parameters += "&" unless first
            k = "c" + k if k == "controller" || k == "action"
            parameters += "#{k}=#{v}"
            first = false
          end
          url += parameters
        end
      else
        url = "/"
      end
      redirect_to url
    else
      current_user.regenerate_auth_token if current_user.auth_token.nil?
    end

    if params['controller'] == 'shows'
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1900 00:00:00 GMT"
    end
  }

end
