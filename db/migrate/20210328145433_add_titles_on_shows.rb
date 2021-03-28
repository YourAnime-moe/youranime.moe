# frozen_string_literal: true
class AddTitlesOnShows < ActiveRecord::Migration[6.1]
  def change
    enable_extension('hstore') unless extension_enabled?('hstore')

    # TODO: add null: false constraint on slug as well as index restriction

    add_column(:shows, :slug, :string)
    add_column(:shows, :titles, :hstore, null: false, default: {})
  end
end
