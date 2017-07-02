class AddTagsToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :tags, :string
  end
end
