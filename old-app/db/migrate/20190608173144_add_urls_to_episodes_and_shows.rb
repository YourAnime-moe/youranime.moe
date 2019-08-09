# frozen_string_literal: true

class AddUrlsToEpisodesAndShows < ActiveRecord::Migration[6.0]
  def change
    add_column :episodes, :thumbnail_url, :string
    add_column :episodes, :caption_url, :string
    add_column :shows, :banner_url, :string
  end
end
