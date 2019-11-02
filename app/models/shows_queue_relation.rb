class ShowsQueueRelation < ApplicationRecord
  belongs_to :show
  belongs_to :queue, class_name: 'Shows::Queue'
end
