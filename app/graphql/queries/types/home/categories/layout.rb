# frozen_string_literal: true
module Queries
  module Types
    module Home
      module Categories
        class Layout < ::Types::BaseEnum
          ::Home::Categories::BaseCategory::LAYOUTS.each do |layout|
            value(layout.to_s.upcase, value: layout)
          end
        end
      end
    end
  end
end
