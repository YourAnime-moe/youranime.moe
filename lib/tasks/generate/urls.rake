# frozen_string_literal: true

namespace :generate do
  desc 'Generate the CDN URLs for Shows and Episodes'
  task urls: :environment do
    Show.published.find_in_batches do |batch|
      Shows::GenerateUrlsJob.perform_later(batch.pluck(:id), force: true)
    end
  rescue Interrupt
    puts ' done by interruption.'
  end
end
