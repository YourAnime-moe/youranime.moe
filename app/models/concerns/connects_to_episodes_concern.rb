# frozen_string_literal: true

module ConnectsToEpisodesConcern
  extend ActiveSupport::Concern

  included do
    connects_to database: { writing: :episodes, reading: :episodes_replica }
  end
end