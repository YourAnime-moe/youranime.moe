class Episode < ApplicationRecord
  include ConnectsToEpisodesConcern

  belongs_to :season, -> { connected_to(role: :reading) { all } }
end
