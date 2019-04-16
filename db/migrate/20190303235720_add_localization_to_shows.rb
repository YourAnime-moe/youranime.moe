class AddLocalizationToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :jp_title, :string
    add_column :shows, :fr_title, :string
    add_column :shows, :roman_title, :string
    add_column :shows, :jp_description, :text
    add_column :shows, :fr_description, :text
  end
end
