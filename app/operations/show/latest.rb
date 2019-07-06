# frozen_string_literal: true

class Show
  class Latest < ApplicationOperation
    input :limit, type: :keyword

    def execute
      latest!
    end

    private

    def latest!
      Show.where(id: show_ids)
    end

    def show_ids
      shows_list.pluck(:id).uniq[0..limit]
    end

    def shows_list
      shows = Show.recent(limit: 1000)
      return shows if shows.any?

      Show.published
    end
  end
end
