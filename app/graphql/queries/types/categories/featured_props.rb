# frozen_string_literal: true
module Queries
  module Types
    module Categories
      class FeaturedProp < ::Types::BaseEnum
        ::Home::Categories::BaseCategory::ALLOWED_FEATURED_PROPS.each do |layout|
          value(layout.to_s.upcase, value: layout)
        end
      end
    end
  end
end
