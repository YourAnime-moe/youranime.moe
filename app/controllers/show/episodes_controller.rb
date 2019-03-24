class Show
  class EpisodesController < AuthenticatedController

    require 'net/http'

    layout 'video-player', only: [:show]

    def show
      @episode = Episode.find_by(id: params[:id])
      if @episode.nil? || !@episode.published?
        flash[:warning] = "Looks like this episode is not available yet. Please try again later."
        redirect_to(@episode.nil? ? shows_path : @episode.show)
      else
        set_title before: "#{@episode.show.get_title} - #{@episode.title}"
        @additional_main_class = 'no-margin no-padding'
      end
    end

    def view
      @anime_current = "current"
      id = params[:id]
      if id.nil?
        flash[:danger] = 'Oops, it looks like an fake episode is with us...'
        redirect_to '/shows'; return
      end
      @episode = Show::Episode.find_by(id: id)
      if @episode.nil?
        flash[:warning] = 'Sorry, it looks like this episode was deleted or does not exit yet. Please try again.'
        redirect_to '/shows'; return
      end
      unless @episode.is_published? and @episode.show.is_published?
        flash[:warning] = 'Sorry, this episode/show is not ready yet. Please try again later.'
        redirect_to '/shows'; return
      end
      @back_url = get_back_url(params, '/shows?id=' + @episode.show.id.to_s)
      @back_title = get_back_title(params, t('anime.episodes.go-back', name: @episode.show.get_title))
      set_title before: t('anime.episodes.title', name: "#{@episode.title}"), after: @episode.show.get_title
    end

    def random
      ind = rand(Show::Episode.last.id)
      episode = nil
      while true
        episode = Show::Episode.find_by(id: ind)
        break unless episode.nil?
        ind = rand(Show::Episode.last.id) + 1
      end
      if episode.is_published?
        redirect_to "/shows/episodes?id=#{ind}"
      else
        redirect_to "/shows/episodes/random"
      end
    end

    def get_subs
      id = params[:id]
      if id.to_s.empty?
        render text: "No episode id was provided."
        return
      end
      episode = Show::Episode.find_by(id: id)
      if episode.nil?
        render text: "Episode number #{id} does not exist."
        return
      end
      unless episode.show.subbed
        render text: "Show #{episode.show.get_title} doesn't seem to be subbed..."
        return
      end

      url = URI.parse(episode.get_new_subtitle_path)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      render text: res.body
    end

    def render_type
      id = params[:id]
      if id.to_s.empty?
        render text: "No episode id was provided."
        return
      end
      episode = Show::Episode.find_by(id: id)
      if episode.nil?
        render text: "Episode number #{id} does not exist."
        return
      end

      type = params[:type].to_s.strip

      if type == "video"
        url = episode.get_new_path
      elsif type == "image"
        path = episode.get_new_image_path
      else
        url = episode.get_path
      end

      url = URI.parse(path)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }

      send_data res.body, filename: episode.title
    end

    def show_episode_video
      episode = Show::Episode.find_by(:id => params[:id])
      if episode.nil?

      else

      end
    end

  end
end
