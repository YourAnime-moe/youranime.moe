# frozen_string_literal: true
module Shows
  class Filter
    extend ProcMe

    attr_reader :tag
    attr_reader :direction
    attr_reader :use_scope

    ACCEPTED_FILTERS = {
      popularity: { ascending: false },
      title: { ascending: true, use_scope: :ordered }, # Use Show.ordered instead of default scope
      starts_on: { ascending: false },
    }.freeze

    def initialize(tag, ascending: nil)
      self.class.ensure_tag!(tag)

      @tag = tag.to_sym
      @use_scope = ACCEPTED_FILTERS.dig(@tag, :use_scope)
      @direction = if ascending.nil?
        ACCEPTED_FILTERS.dig(@tag, :ascending) ? :asc : :desc
      else
        ascending ? :asc : :desc
      end
    end

    def sql_friendly
      "#{tag} #{direction}"
    end

    class << self
      def find_tag!(tag)
        ensure_tag!(tag)

        new(tag)
      end

      def find_tag(tag)
        find_tag!(tag)
      rescue
        nil
      end

      def exists?(tag)
        ACCEPTED_FILTERS.key?(tag.to_sym)
      end

      def ensure_tag!(tag)
        return if exists?(tag)

        raise "Invalid filter tag: `#{tag}'"
      end
    end
  end
end
