# frozen_string_literal: true

module ConnectsToShowsConcern
  extend ActiveSupport::Concern

  included do
    connects_to database: { writing: :shows, reading: :shows_replica }
  end
end