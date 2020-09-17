# frozen_string_literal: true

namespace :generate do
  desc 'Generate the CDN URLs for Shows and Episodes'
  task urls: :environment do
    Show::GenerateUrls.perform(force: true)
    #Episode::GenerateUrls.perform(force: true)
  rescue Interrupt
    puts ' done by interruption.'
  end
end
