class EpisodesController < AuthenticatedController

    def view
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
        current_user.add_episode @episode
    end

end
