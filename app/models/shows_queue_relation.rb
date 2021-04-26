# frozen_string_literal: true
class ShowsQueueRelation < ApplicationRecord
  belongs_to :show, -> { published }, inverse_of: :shows_queue_relations
  belongs_to :queue, class_name: 'Shows::Queue', inverse_of: :shows_queue_relations
  belongs_to :unavailable_show, -> do
    where(published: false)
  end, class_name: 'Show', foreign_key: :show_id, required: false
end
