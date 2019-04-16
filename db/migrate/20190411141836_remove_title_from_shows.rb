class RemoveTitleFromShows < ActiveRecord::Migration[6.0]
  def up
    remove_column :shows, :title
  end

  def down
    add_column :shows, :title, :string
  end
end
