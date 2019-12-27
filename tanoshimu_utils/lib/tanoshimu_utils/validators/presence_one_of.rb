module TanoshimuUtils
  module Validators
    module PresenceOneOf
      extend ActiveSupport::Concern

      class AnyPresenceValidator < ActiveModel::Validator
        def validate(record)
          unless options[:fields].any?{|attr| record[attr].present?}
            record.errors.add(:title, 'must be present (at lease one of en, fr, or jp)')
          end
        end
      end

      class_methods do
        def validate_presence_one_of(one_of)
          validates_with AnyPresenceValidator, fields: one_of
        end
      end
    end
  end
end
