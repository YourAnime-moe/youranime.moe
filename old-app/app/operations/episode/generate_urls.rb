# frozen_string_literal: true

class Episode
  class GenerateUrls < ApplicationOperation
    input :force, type: :keyword, required: false

    before do
      message = "[#{Time.zone.now}] Preparing Episode URL generation..."
      Rails.logger.info message
      Config.slack_client.chat_postMessage(channel: '#tasks', text: message)

      @episodes = Episode.published
      Rails.logger.info "Analyzing #{@episodes.count} episode(s)..."
    end

    def execute
      @episodes.each { |episode| episode.generate_urls!(force: force) }
    end

    succeeded do
      Config.slack_client.chat_postMessage(
        channel: '#tasks',
        text: "[#{Time.zone.now}] Episode URL generation complete."
      )
      Rails.logger.info 'Done.'
    end
  end
end
