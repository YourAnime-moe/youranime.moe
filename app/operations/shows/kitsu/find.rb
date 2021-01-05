module Shows
  module Kitsu
    class Find < ApplicationOperation
      property! :kitsu_ids
      property :force_update, accepts: [true, false], default: false

      def perform
        kitsu_ids.map do |kitsu_id|
          Get.perform(kitsu_id: kitsu_id)
        end
      end
    end
  end
end
