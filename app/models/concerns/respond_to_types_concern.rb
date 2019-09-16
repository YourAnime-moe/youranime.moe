# frozen_string_literal: true

module RespondToTypesConcern
  extend ActiveSupport::Concern

  class_methods do
    def respond_to_types(types)
      raise ArgumentError, 'Expected types Array' unless types.class == Array

      types.each do |type|
        send(:define_method, :"#{type}?") do
          self.user_type == type
        end
      end
    end
  end
end
