class PostCleanUpShows < ActiveRecord::Migration[6.0]
  def change
    # in stead of :recommended and :featured
    add_column :shows, :top_entry, :boolean, default: false, null: false
  end
end
