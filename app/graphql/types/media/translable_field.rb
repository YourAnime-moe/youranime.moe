# frozen_string_literal: true

module Types
  module Media
    class TranslableField < BaseObject
      field :en, String, null: false
      field :fr, String, null: true
      field :jp, String, null: true
    end
  end
end
