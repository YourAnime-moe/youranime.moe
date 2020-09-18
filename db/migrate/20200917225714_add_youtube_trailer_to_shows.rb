class AddYoutubeTrailerToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :youtube_trailer_id, :string
  end
end
