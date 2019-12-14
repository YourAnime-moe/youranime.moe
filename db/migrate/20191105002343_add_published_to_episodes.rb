class AddPublishedToEpisodes < ActiveRecord::Migration[6.1]
  def change
    add_column :episodes, :published, :boolean, default: true, null: false
  end
end
