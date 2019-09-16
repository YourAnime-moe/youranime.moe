class AddEnTitleToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :en_title, :string
    rename_column :shows, :description, :en_description
  end
end
