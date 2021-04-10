# frozen_string_literal: true
module Home
  module Categories
    class MusicVideos < BaseCategory
      def title_template
        'categories.music_videos.title'
      end

      def scopes
        [:as_music, :trending]
      end

      def enabled?
        true
      end
    end
  end
end
