module Shows
  class Queue < ApplicationRecord
    include ConnectsToUsersConcern
  
    belongs_to :user, inverse_of: :queues

    def shows
      ShowsQueueRelation.connected_to(role: :reading) do
        fetch_shows
      end
    end

    def <<(show)
      return unless show.kind_of?(Show)
      return false unless persisted?

      ShowsQueueRelation.connected_to(role: :writing) do
        return show if show_ids.include?(show.id)

        @loaded = false
        ShowsQueueRelation.create!(show_id: show.id, queue_id: id)
      end
    end

    def count
      shows.count
    end

    private

    def show_ids
      return @show_ids if @show_ids && @loaded

      @loaded = false
      @show_ids ||= ShowsQueueRelation.where(queue_id: id).pluck(:show_id)
    end

    def fetch_shows
      Show.where(id: show_ids)
    end
  end  
end
