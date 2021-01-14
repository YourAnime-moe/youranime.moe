# frozen_string_literal: true
module Shows
  class ReleaseSchedule < ApplicationOperation
    property :platform, accepts: Platform

    def perform
      @schedule = {
        sunday: { id: 0 },
        monday: { id: 1 },
        tuesday: { id: 2 },
        wednesday: { id: 3 },
        thursday: { id: 4 },
        friday: { id: 5 },
        saturday: { id: 6 },
      }

      populate_schedule!
      schedule_into_2d_array
    end

    private

    def populate_schedule!
      @longest_column_size = 0
      @total_count = 0

      @schedule.each do |_, day|
        shows = shows_scope.select do |show|
          show.starts_on.wday == day[:id]
        end
        day[:count] = shows.count
        day[:shows] = shows

        @total_count += day[:count]
        @longest_column_size = day[:count] if @longest_column_size < day[:count]
      end

      @schedule
    end

    def schedule_into_2d_array
      actual_schedule = Array.new(7) { Array.new(@longest_column_size) }
      @schedule.each_with_index do |schedule_info, i|
        actual_schedule[i] = @longest_column_size.times.collect { |j| schedule_info[1][:shows][j] }
      end

      # automatic transpose
      results = actual_schedule.transpose

      # manual transpose - I came up with this (didn't know about the method :p)
      # this is just for reference
      # results = Array.new(@longest_column_size) { Array.new(7) }

      # actual_schedule.each_with_index do |row, i|
      #   row.each_with_index do |_, j|
      #     results[j][i] = row[j]
      #   end
      # end

      # byebug

      [@schedule, results, @total_count]
    end

    def shows_scope
      platform ? platform.shows.active : Show.active.with_links
    end
  end
end
