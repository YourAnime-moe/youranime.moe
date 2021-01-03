# frozen_string_literal: true
class ShowsQueueRelation < ApplicationRecord
  belongs_to :show, -> { published }, inverse_of: :shows_queue_relations
  belongs_to :unavailable_show, -> {
                                  where(published: false)
                                }, class_name: 'Show', foreign_key: :show_id, required: false
  belongs_to :queue, class_name: 'Shows::Queue', inverse_of: :shows_queue_relations
end
