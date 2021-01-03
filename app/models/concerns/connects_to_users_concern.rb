# frozen_string_literal: true

module ConnectsToUsersConcern
  extend ActiveSupport::Concern

  included do
    connects_to database: { writing: :users, reading: :users_replica }
  end
end
