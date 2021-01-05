# frozen_string_literal: true

namespace :generate do
  desc 'Generate the CDN URLs for Shows and Episodes'
  task urls: :environment do
    Shows::GenerateUrlsJob.perform_later(force: true)
  rescue Interrupt
    puts ' done by interruption.'
  end
end
