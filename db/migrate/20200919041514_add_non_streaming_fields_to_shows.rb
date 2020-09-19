class AddNonStreamingFieldsToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :age_rating, :string, default: 'NR'
    add_column :shows, :age_rating_guide, :string
    add_column :shows, :show_category, :string # use for game region.
    add_column :shows, :status, :string, default: 'finished'
    add_column :shows, :starts_on, :date # use for game release date.
    add_column :shows, :ended_on, :date
    add_column :shows, :nsfw, :boolean, default: false, null: false
    add_column :shows, :episodes_count, :integer, default: 0, null: false
  end
end
