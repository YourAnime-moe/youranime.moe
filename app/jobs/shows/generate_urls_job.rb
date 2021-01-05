# frozen_string_literal: true
module Shows
  class GenerateUrlsJob < TrackableJob
    def perform(force: true)
      Show::GenerateUrls.perform(force: force)
    end
  end
end
