# frozen_string_literal: true

namespace :sync do
  namespace :shows do
    namespace :update do
      task later: :environment do
        Show.find_in_batches.each do |batch|
          show_ids = batch.map(&:id)

          ::Sync::Shows::UpdateShowsJob.perform_later(
            show_ids,
            staff: Users::Admin.system,
          )
        end
      end

      task now: :environment do
        Show.find_in_batches.each do |batch|
          show_ids = batch.map(&:id)

          ::Sync::Shows::UpdateShowsJob.perform_now(
            show_ids,
            staff: Users::Admin.system,
          )
        end
      end
    end

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

    namespace :anilist do
      desc 'Fetch additional show information from anilist.co'
      task airing_schedule: :environment do
        Show.streamable.airing.find_in_batches(batch_size: 10).each do |shows_batch|
          ::Sync::Shows::UpdateAiringScheduleJob.perform_later(
            shows_batch.map(&:id),
            staff: Users::Admin.system,
          )
        end
      end
    end

    namespace :crawl do
      desc 'Crawls all shows (and updates) all available shows from kitsu.io'
      task :later, [:start, :end] => [:environment] do |_, args|
        Sync::Shows::CrawlFromKitsuJob.perform_later(
          args[:start].to_i,
          args[:end].to_i,
          staff: Users::Admin.system,
        )
      end
      task :now, [:start, :end] => [:environment] do |_, args|
        Sync::Shows::CrawlFromKitsuJob.perform_now(
          args[:start].to_i,
          args[:end].to_i,
          staff: Users::Admin.system,
        )
      end
    end
  end
end
