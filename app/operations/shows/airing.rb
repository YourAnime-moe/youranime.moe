# frozen_string_literal: true
module Shows
  class Airing < ApplicationOperation
    property! :date, converts: :to_date

    def perform
      Show.tv.where(id: airing_shows_ids).order(:status)
    end

    private

    def airing_shows_ids
      shows_scope.select do |show|
        show.starts_on.wday == date.wday
      end.map(&:id)
    end

    def shows_scope
      @shows_scope ||= Show.with_title
        .trending
        .where(
          "starts_on <= '#{date}'"
        ).where(
          "ended_on >= '#{date}'"
        ).or(
          Show.where(ended_on: nil)
            .where
            .not(starts_on: nil)
        )
    end
  end
end
