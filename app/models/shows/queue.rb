module Shows
  class Queue < ApplicationRecord
    belongs_to :user, inverse_of: :queues

    has_many :shows_queue_relations
    has_many :shows, -> { reverse_order }, through: :shows_queue_relations
    has_many :unavailable_shows, class_name: 'Show', through: :shows_queue_relations

    def <<(show)
      return unless show.kind_of?(Show)
      return false unless persisted?

      return show if reload.shows.include?(show)

      @loaded = false
      shows_queue_relations.create!(show_id: show.id)
    end

    def -(show)
      return unless show.kind_of?(Show)
      return unless include?(show)

      shows_queue_relations.find_by(show: show).destroy
    end

    def include?(show)
      shows_queue_relations.where(show: show).exists?
    end

    def count
      shows.count
    end

    private

    def show_ids
      return @show_ids if @show_ids && @loaded

      @loaded = true
      @show_ids ||= shows_queue_relations.pluck(:show_id)
    end
  end  
end
