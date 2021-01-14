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
    end

    private

    def populate_schedule!
      @schedule.each do |_, day|
        shows = shows_scope.select do |show|
          show.starts_on.wday == day[:id]
        end
        day[:count] = shows.count
        day[:shows] = shows
      end

      @schedule
    end

    def shows_scope
      platform ? platform.shows.active : Show.active.with_links
    end
  end
end
