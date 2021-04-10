# frozen_string_literal: true
module Home
  module Categories
    module Platforms
      class BaseExclusiveOn < BaseCategory
        def title_template
          "categories.exclusive_on_platform.title"
        end

        def title_params
          { platform: platform.title }
        end

        def enabled?
          false
        end

        def self.default_scope
          Show.exclusive_on(platform_name).order('starts_on desc')
        end

        def self.platform_name
          raise 'Invalid platform name'
        end

        private

        def platform
          Platform.find_by!(name: self.class.platform_name)
        end
      end
    end
  end
end
