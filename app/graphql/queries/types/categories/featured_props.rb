# frozen_string_literal: true
module Queries
  module Types
    module Categories
      class FeaturedProp < ::Types::BaseEnum
        value('AIRING_AT', value: 'airing_at')
        value('FRIENDLY_STATUS', value: 'friendly_status')
        value('YEAR', value: 'year')
      end
    end
  end
end
