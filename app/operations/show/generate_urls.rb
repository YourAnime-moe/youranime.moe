# frozen_string_literal: true

class Show
  class GenerateUrls < ApplicationOperation
    input :force, type: :keyword, required: false

    before do
      puts 'Generating URLs for Shows...'
      message = "[#{Time.zone.now}] Preparing Show URL generation..."
      Rails.logger.info message
      #Config.slack_client&.chat_postMessage(channel: '#tasks', text: message)

      @shows = Show.published
      Rails.logger.info "Analyzing #{@shows.count} show(s)..."
    end

    def execute
      printf('Generating for shows: ')
      @successful_ids = []
      @shows.each do |show|
        result = show.generate_banner_url!(force: force)
        @successful_ids << show.id if result && show.banner?
      end
      puts "#{@successful_ids.join(', ')} done."
    end

    succeeded do
      #Config.slack_client&.chat_postMessage(
      #  channel: '#tasks',
      #  text: "[#{Time.zone.now}] URL for #{@successful_ids.count} show(s) generation complete."
      #)
      Rails.logger.info 'Done.'
    end
  end
end
