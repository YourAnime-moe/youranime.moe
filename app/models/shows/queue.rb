# frozen_string_literal: true
module Shows
  class Queue < ApplicationRecord
    belongs_to :user, inverse_of: :queues

    has_many :shows_queue_relations, -> { includes(:show, :queue).reverse_order }, inverse_of: :queue
    has_many :shows, through: :shows_queue_relations
    has_many :unavailable_shows, class_name: 'Show', through: :shows_queue_relations

    def <<(show)
      return unless show.is_a?(Show)
      return false unless persisted?

      return show if reload.shows.include?(show)

      @loaded = false
      shows_queue_relations.create!(show_id: show.id)
    end

    def -(other)
      return unless other.is_a?(Show)
      return unless include?(other)

      shows_queue_relations.find_by(show: other).destroy
    end

    def include?(show)
      shows_queue_relations.where(show: show).exists?
    end

    def count
      shows.count
    end

    def empty?
      !any?
    end

    def any?
      count > 0
    end

    def present?
      any?
    end

    def blank?
      empty?
    end

    def published_shows_queue_relations
      shows_queue_relations.where(show_id: Show.published)
    end

    private

    def show_ids
      return @show_ids if @show_ids && @loaded

      @loaded = true
      @show_ids ||= shows_queue_relations.pluck(:show_id)
    end
  end
end
