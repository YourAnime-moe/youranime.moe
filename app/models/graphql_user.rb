# frozen_string_literal: true

class GraphqlUser < ApplicationRecord
  has_many :queues, -> {
    includes(shows_queue_relations: {
      show: [:description_record, :ratings],
    })
  }, class_name: 'Shows::Queue', inverse_of: :graphql_user

  def add_show_to_main_queue(show)
    return unless show.present?
    return true if main_queue.include?(show)

    (main_queue << show).valid?
  end

  def remove_show_from_main_queue(show)
    return unless show.present?

    (main_queue - show)&.destroyed?
  end

  def has_show_in_main_queue?(show)
    show.present? && main_queue.include?(show)
  end

  def main_queue
    @main_queue ||= queues.empty? ? queues.create! : queues.first
  end
end
