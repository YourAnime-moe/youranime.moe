class CleanUpShows < ActiveRecord::Migration[6.0]
  def change
    remove_column :shows, :dubbed
    remove_column :shows, :subbed
    remove_column :shows, :plot
    remove_column :shows, :published_on
    remove_column :shows, :recommended
    remove_column :shows, :featured
  end
end
