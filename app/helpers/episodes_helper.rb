module EpisodesHelper

  def videojs_version
    Config.videojs
  end

  def episode_tag(episode)
    content_tag :video, controls: false, muted: true, autoplay: true, id: 'video-obj', src: @episode.video_url, watched: current_user.progress_for(episode) do
      episode.subtitles.select{|sub| sub.src.attached?}.map do |s|
        text = <<-HTML
          <track kind="subtitles" load-src="#{url_for(s.src)}" srclang="#{s.lang}" label="#{s.name}">
        HTML
      end.join('').html_safe
    end
  end

  def restricted?(episode)
    !!current_user.google_user && episode.respond_to?(:restricted?) && episode.restricted?
  end

end
