# frozen_string_literal: true

namespace :generate do
  desc 'Generate'
  task urls: :environment do
    printf 'Generating URLs for Shows...'
    Show::GenerateUrls.perform(force: true)
    puts ' done.'
    printf 'Generating URLs for Episodes...'
    Episode::GenerateUrls.perform(force: true)
    puts ' done.'
  rescue Interrupt
    puts ' done by interruption.'
  end
end
