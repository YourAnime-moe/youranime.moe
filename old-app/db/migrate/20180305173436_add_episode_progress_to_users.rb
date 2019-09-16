class AddEpisodeProgressToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :episode_progress_list, :string
  end
end
