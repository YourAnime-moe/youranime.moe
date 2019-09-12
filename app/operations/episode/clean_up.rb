# frozen_string_literal: true

class Episode
  class CleanUp < ApplicationOperation
    def execute
      Episode.all.each do |episode|
        purge_thumbnails_for! episode
        make_thumbnail_for! episode
        purge_videos_for! episode
        make_video_for! episode
      end
    end

    private

    def purge_thumbnails_for!(episode)
      Rails.logger.info "Cleaning thumbnail for episode id #{episode.id}"
      episode.thumbnail.purge if episode.thumbnail.attached?
    end

    def make_thumbnail_for!(episode)
      Rails.logger.info "Making thumbnail for episode id #{episode.id}"
      episode.get_thumbnail
    end

    def purge_videos_for!(episode)
      Rails.logger.info "Cleaning video for episode id #{episode.id}"
      episode.video.purge if episode.video.attached?
    end

    def make_video_for!(episode)
      Rails.logger.info "Making video for episode id #{episode.id}"
      episode.get_video
    end
  end
end
