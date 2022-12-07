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
      LAYOUTS = %i(
        simple
        expanded
      ).freeze

      ALLOWED_FEATURED_PROPS = %i(
        airing_at
        year
        friendly_status
        next_episode
      )

      class NotImplemented < StandardError
        def message
          "This category's title was not implemented!"
        end
      end

      class ConfigurationError < StandardError; end

      def initialize(context:, filters: [])
        @context = Hash(context)
        @filters = filters
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

      # Show attributes that should be displayed on the thumbnail.
      # See possible values on: ALLOWED_FEATURED_PROPS
      # Used by Queries::Types::Categories::FeaturedProp.
      # Please use #featured_props to get the clean list of thumbnail props.
      # Please do not override #featured_props. This could result in unnecessary server errors.
      def thumbnail_attributes
        [:year]
      end

      def shows_override
      end

      def cacheable?
        false
      end

      def cache_expires_in
        1.day
      end

      ## Internal attributes
      def title
        I18n.translate(title_template, **title_params)
      end

      def key
        title.parameterize
      end

      def visible?
        enabled? && valid_title?
      end

      def shows
        ensure_enabled!
        return @shows if @shows.present?
        return @shows if !(@shows = shows_override).nil?

        @shows = cacheable? ? cached_compute_shows : compute_shows
      end

      def shows_by_year
        return @shows_by_year if @shows_by_year

        grouped_shows = shows.where.not(starts_on: nil).order(:starts_on).group_by(&:year)
        @shows_by_year = grouped_shows.each_with_object([]) do |item, result|
          result << ::Shows::GroupByYear.new(year: item[0], shows: item[1])
        end
      end

      def featured_props
        thumbnail_attributes.map do |attribute|
          attribute.to_sym
        rescue
          nil
        end.compact.select do |attribute|
          ALLOWED_FEATURED_PROPS.include?(attribute)
        end
      end

      def validate!
        ensure_layout!
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
      attr_reader :filters

      private

      def valid_title?
        I18n.exists?(title_template) && title.present?
      rescue => e
        Rails.logger.error(e)
        false
      end

      def ensure_layout!
        unless LAYOUTS.include?(layout)
          raise ConfigurationError, "Invalid layout: #{layout}. Must be one of: #{LAYOUTS.join(', ')}"
        end
      end

      def ensure_enabled!
        unless enabled?
          raise ConfigurationError, "#{self.class.name} is not enabled"
        end
      end

      def cached_compute_shows
        cache_key = "category-#{key}"

        cached_shows = Rails.cache.read(cache_key)
        if cached_shows.present?
          Rails.logger.info("[#{self.class}] Restauring from cache key `#{cache_key}`")
          return cached_shows
        end

        shows = compute_shows
        Rails.cache.write(cache_key, shows, expires_in: cache_expires_in)
        shows
      end

      def compute_shows
        default_scope = self.class.default_scope
        if default_scope.is_a?(Array)
          Rails.logger.warn('Ignoring #scopes due to default scope being an array')
          return default_scope
        end

        all_shows = scopes.inject(self.class.default_scope) do |current_scope, new_scope|
          current_scope.send(new_scope)
        end

        return all_shows if filters.empty?

        searched_show_ids = if filters[:search_term].present?
          Show.search(filters[:search_term]).ids
        else
          []
        end

        if filters[:tags].present?
          all_shows = all_shows.by_tags(*filters[:tags])
        end

        if filters[:platforms].present?
          all_shows = all_shows.streamable_on(filters[:platforms])
        end

        if filters[:year].present?
          all_shows = if filters[:season].present?
            all_shows.by_season(season: filters[:season], year: filters[:year])
          else
            all_shows.by_year(filters[:year])
          end
        end

        filters[:search_term].present? ? all_shows.where(id: searched_show_ids) : all_shows
      end
    end
  end
end
