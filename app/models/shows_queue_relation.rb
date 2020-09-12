class ShowsQueueRelation < ApplicationRecord
  belongs_to :show, -> { published }
  belongs_to :unavailable_show, -> { where(published: false) }, class_name: 'Show', foreign_key: :show_id
  belongs_to :queue, class_name: 'Shows::Queue'
end
