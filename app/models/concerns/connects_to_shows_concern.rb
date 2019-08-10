# frozen_string_literal: true

module ConnectsToShowsConcern
  extend ActiveSupport::Concern

  included do
    connects_to database: { writing: :users, reading: :users_replica }
  end
end