# frozen_string_literal: true
module Shows
  module Kitsu
    module List
      class PerStreamer < ApplicationOperation
        property! :name, accepts: ShowUrl::STREAMABLE_URL_TYPES, converts: :to_sym

        def perform
          Shows::Kitsu::Sync::ShowsPerPage.perform(
            params: { streamers: name },
            requested_by: Users::Admin.system,
          )
        end
      end
    end
  end
end
