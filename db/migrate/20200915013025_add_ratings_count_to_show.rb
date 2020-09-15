class AddRatingsCountToShow < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :likes_count, :integer, default: 0, null: false
    add_column :shows, :dislikes_count, :integer, default: 0, null: false
    add_column :shows, :loves_count, :integer, default: 0, null: false
  end
end
