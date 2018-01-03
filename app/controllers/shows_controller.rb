class ShowsController < AuthenticatedController

    def view
        @anime_current = "current"
        if params[:view] == 'all'
            view_all
            return
        end
        if params[:id]
            @show = Show.find_by(id: params[:id])
            if @show && @show.is_published?
                set_title(:before => @show.get_title)
                @back_url = get_back_url(params, @show.is_movie? ? "/movies" : "/shows")
                @back_title = get_back_title(params, "Go back to " + (@show.is_movie? ? "movies" : "shows"))
                render 'view'
            elsif @show && !@show.is_published?
                flash[:warning] = "This show is not available yet. Please try again later."
                redirect_to '/shows'
            else
                flash[:danger] = "This show was not found. Please try again."
                redirect_to '/shows'
            end
            return
        end
        title = params[:title]
        show_number = params[:showNumber]
        if show_number.nil?
            show_number = params[:show_number]
        end
        if title.nil? || show_number.nil?
            @shows = Show.all.select {|show| show.is_anime? && !show.get_title.nil?}
            @shows = @shows.to_a.sort_by(&:get_title)
            @shows.select! {|s| s.is_published?}
            shows = @shows.each_slice(2).to_a
            @split_shows = []
            shows.each do |show_group|
                new_group = []
                if show_group.size == 1
                    new_group.push show_group[0]
                else
                    first = show_group[0]
                    second = show_group[1]
                    if first.get_title > second.get_title
                        tmp = first
                        first = second
                        second = tmp
                    end
                    new_group.push first
                    new_group.push second
                end
                @split_shows.push new_group
            end
            @split_shows
            # @split_shows = Utils.split_array(Show, sort_by: 2)
            set_title(:before => "Shows")
            render 'view_all'; return
        end
        Show.all.each do |show|
            if show.title = title and show.show_number.to_s == show_number
                @show = show; break
            end
        end
        if @show.nil?
            flash[:danger] = "Sorry, no show using the given parameters was not found. Please try again."
            redirect_to '/'; return
        end
        p @show
    end

    def view_all
        @anime_current = "current"
        @shows = Show.all
    end

    def history
        @anime_current = "current"
        episodes = current_user.get_episodes_watched
        if episodes.empty?
          flash[:warning] = "Sorry, we don't know which epsiodes you've watched yet."
          redirect_to '/'
          return
        end
        @episodes = episodes.map{|e| Episode.find(e)}
        @episodes.select!{|e| e.is_published?}
        @episodes.reverse!
        set_title before: "Episode history", after: "What have you watched so far?"
    end

    def search
        @search = true
    end

    def tags
        
    end

    def render_img
        id = params[:id]
        if id.to_s.empty?
            render text: "No show id was provided."
            return
        end
        show = Show.find_by(id: id)
        if show.nil?
            render text: "Show number #{id} does not exist."
            return
        end

        path = show.get_new_image_path

        url = URI.parse(path)
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
        
        send_data res.body, filename: "#{show.get_title}"
    end

end
