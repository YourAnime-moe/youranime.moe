# frozen_string_literal: true
### Usage
# In order to define a category, a sub class extending Home::Category must be defined.
# All public methods defined here can be overrided.
#
# class MyCategory < Home::Categories::BaseCategory
#   def title_template
#     'Your title'
#   end
#
#   # other methods
# end
#
# See app/graphql/queries/types/home_page_category.rb to see which fields are exposed
# to the GraphQL API.
#
### Layouts
# simple: The default layout. A title and a list of shows. An optional description.
#

module Home
  module Categories
    class BaseCategory
      LAYOUT = %i(
        simple
      ).freeze

      class NotImplemented < StandardError
        def message
          'This category was not implemented!'
        end
      end

      class ConfigurationError < StandardError; end

      def initialize(context:)
        @context = Hash(context)
      end

      ## Must override
      # The template for the title of the category. Built title
      # available with method #title. Must be an I18n string.
      def title_template
        raise Home::Categories::BaseCategory::NotImplemented
      end

      ## Customizable attributes you can override.
      # Callable scopes on the `Show` model.
      # Default: all Shows (Show.all)
      #
      # If you want trending and published shows, scopes will have
      # to be:
      # [:trending, :published]
      def scopes
        [:all]
      end

      # The layout of the category
      def layout
        :simple
      end

      # Intepolate those parameters to the title.
      # Ex: If the I18n template is "Title for {place}"
      #
      # then title_params would need to be
      # {place: 'my place'}
      #
      # Title would then be "Title for my place".
      def title_params
        {}
      end

      # The description of the category
      def description
        nil
      end

      # Any warning the user should be aware of
      def warning
        nil
      end

      # Should this category be visible on the UI
      def enabled?
        false
      end

      def can_fetch_more?
        false
      end

      ## Internal attributes
      def title
        I18n.translate(title_template, title_params)
      end

      def visible?
        enabled? && valid_title?
      end

      def shows
        @shows ||= compute_shows
      end

      def inspect
        "#<#{self.class.name} title=\"#{title}\" scopes=[#{scopes.join(', ')}]>"
      rescue
        "#<UnimplementedCategory [scopes: (#{scopes.join(', ')})]>"
      end

      def self.default_scope
        Show.all
      end

      protected

      attr_reader :context

      private

      def valid_title?
        I18n.exists?(title_template) && title.present?
      rescue => e
        Rails.logger.error(e)
        false
      end

      def compute_shows
        scopes.inject(self.class.default_scope) do |current_scope, new_scope|
          current_scope.send(new_scope)
        end
      end
    end
  end
end
