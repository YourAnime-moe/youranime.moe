module TanoshimuUtils
  module Validators
    module UserLike
      extend ActiveSupport::Concern
    
      class_methods do
        def validate_like_user(user_types:)
          raise ArgumentError, 'Expected users types' unless user_types.class == Array
    
          validates :username, presence: true, uniqueness: true
          validates :name, presence: true
          validates :user_type, inclusion: { in: user_types }
        end
      end
    end
  end
end
