# frozen_string_literal: true

namespace :sync do
  namespace :shows do
    namespace :kitsu do
      desc 'Fetch and update the currently airing and upcoming shows from kitsu.io'
      task later: :environment do
        Sync::ShowsFromKitsuJob.perform_later(staff: Users::Admin.system)
      end
      task now: :environment do
        Sync::ShowsFromKitsuJob.perform_now(staff: Users::Admin.system)
      end
    end

    namespace :crawl do
      desc 'Crawls all shows (and updates) all available shows from kitsu.io'
      task later: :environment do
        Sync::Shows::CrawlFromKitsuJob.perform_later(staff: Users::Admin.system)
      end
      task now: :environment do
        Sync::Shows::CrawlFromKitsuJob.perform_now(staff: Users::Admin.system)
      end
    end
  end
end
