class AddRankToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :rank, :integer
  end
end
