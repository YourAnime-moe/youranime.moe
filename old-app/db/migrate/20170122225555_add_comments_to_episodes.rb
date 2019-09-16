class AddCommentsToEpisodes < ActiveRecord::Migration[5.0]
  def change
    add_column :episodes, :comments, :string
  end
end
