# frozen_string_literal: true
module Shows
  class GroupByYear
    attr_reader :year
    attr_reader :shows

    delegate :size, :count, :length, to: :shows

    def initialize(year:, shows:)
      @year = year
      @shows = shows
    end

    def inspect
      "#<Shows::GroupByYear year='#{year}' shows(#{shows.size})>"
    end
  end
end
