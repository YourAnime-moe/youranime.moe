module Users
  class ApiController < AuthenticatedController
    def latest_shows
      latest = Show.latest(current_user)
      res = []
      latest.each do |l|
          image_path = l.get_image_path
          result = l.to_json
          result = JSON.parse result
          result[:full_icon_url] = image_path
          res.push result
      end
      respond_to do |format|
        format.html { render json: res }
        format.json { render json: res }
        format.xml { render xml: res }
      end
    end
  end
end
