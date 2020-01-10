# frozen_string_literal: true

class Show
  class GenerateUrls < ApplicationOperation
    input :force, type: :keyword, required: false

    before do
      message = "[#{Time.zone.now}] Preparing Show URL generation..."
      Rails.logger.info message
      Config.slack_client&.chat_postMessage(channel: '#tasks', text: message)

      @shows = Show.published
      Rails.logger.info "Analyzing #{@shows.count} show(s)..."
    end

    def execute
      @shows.each { |show| show.generate_banner_url!(force: force) }
    end

    succeeded do
      Config.slack_client&.chat_postMessage(
        channel: '#tasks',
        text: "[#{Time.zone.now}] Show URL generation complete."
      )
      Rails.logger.info 'Done.'
    end
  end
end
