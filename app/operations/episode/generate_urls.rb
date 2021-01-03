# frozen_string_literal: true

class Episode
  class GenerateUrls < ApplicationOperation
    input :force, type: :keyword, required: false

    before do
      puts 'Generating URLs for Episodes...'
      message = "[#{Time.zone.now}] Preparing Episode URL generation..."
      Rails.logger.info(message)
      Config.slack_client.chat_postMessage(channel: '#tasks', text: message)

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
      Config.slack_client.chat_postMessage(
        channel: '#tasks',
        text: "[#{Time.zone.now}] URL for #{@successful_ids.count} episode(s) URL generation complete."
      )
      Rails.logger.info('Done.')
    end
  end
end
