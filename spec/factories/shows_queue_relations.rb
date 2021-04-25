# frozen_string_literal: true
FactoryBot.define do
  factory :shows_queue_relation do
    show
    queue factory: :shows_queue
  end
end
