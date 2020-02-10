module Shows
  class Queue < ApplicationRecord
    belongs_to :user, inverse_of: :queues

    has_many :shows_queue_relations
    has_many :shows, through: :shows_queue_relations

    def <<(show)
      return unless show.kind_of?(Show)
      return false unless persisted?

      return show if reload.shows.include?(show)

      @loaded = false
      shows_queue_relations.create!(show_id: show.id)
    end

    def count
      shows.count
    end

    def inspect
      shows.inspect
    end

    private

    def show_ids
      return @show_ids if @show_ids && @loaded

      @loaded = true
      @show_ids ||= shows_queue_relations.pluck(:show_id)
    end
  end  
end
