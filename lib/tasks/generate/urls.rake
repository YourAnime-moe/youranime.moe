# frozen_string_literal: true

namespace :generate do
  desc 'Generate the CDN URLs for Shows and Episodes'
  task urls: :environment do |task|
    Show.published.find_in_batches do |batch|
      Shows::GenerateUrlsJob.perform_later(batch.pluck(:id), force: true, task: task.name)
    end
  rescue Interrupt
    puts ' done by interruption.'
  end
end
