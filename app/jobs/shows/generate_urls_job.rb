# frozen_string_literal: true
module Shows
  class GenerateUrlsJob < TrackableJob
    def perform(show_ids, force: true, task: nil)
      Show::GenerateUrls.perform(shows: Show.find(show_ids), force: force)
    end
  end
end
