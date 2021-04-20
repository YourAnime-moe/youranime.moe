# frozen_string_literal: true
module Types
  class MutationType < Types::BaseObject
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end

    field :add_to_main_queue, Queries::Types::Show, null: true do
      argument :slug, String, required: true
    end

    def add_to_main_queue(slug:)
      show = Show.find_by(slug: slug)
      context[:current_user]&.add_show_to_main_queue(show) ? show : nil
    end

    field :remove_from_main_queue, Queries::Types::Show, null: true do
      argument :slug, String, required: true
    end

    def remove_from_main_queue(slug:)
      show = Show.find_by(slug: slug)
      context[:current_user]&.remove_show_from_main_queue(show) ? show : nil
    end
  end
end
