# frozen_string_literal: true

class Episode
  class GenerateUrls < ApplicationOperation
    input :force, type: :keyword, required: false

    before do
      puts 'Generating URLs for Episodes...'
      message = "[#{Time.zone.now}] Preparing Episode URL generation..."
      Rails.logger.info(message)

      @episodes = Episode.published
      Rails.logger.info("Analyzing #{@episodes.count} episode(s)...")
    end

    def execute
      printf('Generating for episodes: ')
      @successful_ids = []
      @episodes.each do |episode|
        result = episode.generate_thumbnail_url!(force: force)
        @successful_ids << episode.id if result && episode.thumbnail?
      end
      puts "#{@successful_ids.join(', ')} done."
    end

    succeeded do
      Rails.logger.info('Done.')
    end
  end
end
