# frozen_string_literal: true
module Shows
  module Kitsu
    module Sync
      class UpdateExisting < ApplicationOperation
        property :force_update, accepts: [true, false], default: false

        def perform
          Show.published.each do |show|
            next unless show.synchable? && show.reference_source == 'kitsu'

            Shows::Kitsu::Get.perform(
              kitsu_id: show.reference_id,
              force_update: force_update,
            )
          rescue Shows::Kitsu::Get::NotFound => e
            puts "Error while getting show: #{e}"
          end
        end
      end
    end
  end
end
