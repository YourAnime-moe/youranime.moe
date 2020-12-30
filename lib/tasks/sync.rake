# frozen_string_literal: true

namespace :sync do
  namespace :shows do
    namespace :kitsu do
      desc 'Fetch and update the currently airing and upcoming shows from kitsu.io'
      task later: :environment do
        %i(current next).each do |season|
          Sync::ShowsFromKitsuJob.perform_later(season, staff: Users::Admin.system)
        end
      end
      task now: :environment do
        %i(current next).each do |season|
          Sync::ShowsFromKitsuJob.perform_now(season, staff: Users::Admin.system)
        end
      end
    end

    namespace :crawl do
      desc 'Crawls all shows (and updates) all available shows from kitsu.io'
      task :later, [:start, :end] => [:environment] do |_, args|
        Sync::Shows::CrawlFromKitsuJob.perform_later(
          ((args[:start].to_i)..(args[:end].to_i)),
          staff: Users::Admin.system,
        )
      end
      task :now, [:start, :end] => [:environment] do |_, args|
        Sync::Shows::CrawlFromKitsuJob.perform_now(
          ((args[:start].to_i)..(args[:end].to_i)),
          staff: Users::Admin.system,
        )
      end
    end
  end
end
