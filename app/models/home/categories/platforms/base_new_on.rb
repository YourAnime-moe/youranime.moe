# frozen_string_literal: true
module Home
  module Categories
    module Platforms
      class BaseNewOn < BaseCategory
        def title_template
          "categories.new_on_platform.title"
        end

        def title_params
          { platform: platform.title }
        end

        def enabled?
          context[:country] ? platform.available?(context[:country]) : true
        end

        def thumbnail_attributes
          [:year, :friendly_status]
        end

        def self.default_scope
          Show.streamable_on(platform_name).order('starts_on desc')
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
