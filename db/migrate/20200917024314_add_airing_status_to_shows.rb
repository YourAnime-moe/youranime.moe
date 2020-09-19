class AddAiringStatusToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :airing_status, :string, default: 'unknown', null: false
  end
end
