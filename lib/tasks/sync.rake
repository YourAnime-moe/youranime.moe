# frozen_string_literal: true

namespace :sync do
  namespace :shows do
    desc 'Fetch and update the currently airing and upcoming shows from kitsu.io'
    task kitsu_airing: :environment do
      Sync::ShowsFromKitsuJob.perform_later(staff: Staff.system)
    end

    desc 'Crawls all shows (and updates) all available shows from kitsu.io'
    task crawl: :environment do
      Sync::Shows::CrawlFromKitsuJob.perform_later(staff: Staff.system)
    end
  end
end
