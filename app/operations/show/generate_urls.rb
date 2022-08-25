# frozen_string_literal: true

class Show
  class GenerateUrls < ApplicationOperation
    input :shows, type: :keyword, required: true
    input :force, type: :keyword, required: false

    before do
      puts 'Generating URLs for Shows...'
      Rails.logger.info("[#{Time.zone.now}] Preparing Show URL generation...")
      Rails.logger.info("Analyzing #{shows.count} show(s)...")
    end

    def execute
      printf('Generating for shows: ')
      @successful_ids = []
      shows.each do |show|
        result = show.update_banner_and_poster_urls!(force: force)
        @successful_ids << show.id if result && show.banner? && show.poster?
        printf(result ? '.' : 'F')
      end
      puts "#{@successful_ids.join(', ')} done."
    end

    succeeded do
      Rails.logger.info('Done.')
    end
  end
end
