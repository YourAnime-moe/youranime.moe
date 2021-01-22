# frozen_string_literal: true
module Queries
  module Types
    module Shows
      class AiringStatus < ::Types::BaseEnum
        description 'The airing status of a show. Enum values.'

        ::Show::SHOW_STATUSES.each do |show_status|
          value(show_status.upcase, value: show_status)
        end
      end
    end
  end
end
