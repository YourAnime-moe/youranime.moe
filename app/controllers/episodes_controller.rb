class EpisodesController < AuthenticatedController

    def view
        @anime_current = "current"
        id = params[:id]
        if id.nil?
            flash[:danger] = 'Oops, it looks like an fake episode is with us...'
            redirect_to '/shows'; return
        end
        @episode = Episode.find_by(id: id)
        if @episode.nil?
            flash[:warning] = 'Sorry, it looks like this episode was deleted or does not exit yet. Please try again.'
            redirect_to '/shows'; return
        end
        unless @episode.is_published? and @episode.show.is_published?
            flash[:warning] = 'Sorry, this episode/show is not ready yet. Please try again later.'
            redirect_to '/shows'; return
        end
        @back_url = get_back_url(params, '/shows?id=' + @episode.show.id.to_s)
        @back_title = get_back_title(params, "Go back to #{@episode.show.get_title}")
        set_title before: "You are watching \"#{@episode.title}\"", after: @episode.show.get_title
    end

    def random
        ind = rand(Episode.last.id)
        episode = nil
        while true
            episode = Episode.find_by(id: ind)
            break unless episode.nil?
            ind = rand(Episode.last.id) + 1
        end
        if episode.is_published?
            redirect_to "/shows/episodes?id=#{ind}"
        else
            redirect_to "/shows/episodes/random"
        end
    end

end
