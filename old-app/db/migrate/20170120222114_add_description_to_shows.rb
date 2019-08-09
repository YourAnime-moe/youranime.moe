class AddDescriptionToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :description, :string
  end
end
