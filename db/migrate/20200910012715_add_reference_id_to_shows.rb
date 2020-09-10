class AddReferenceIdToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :reference_id, :bigint
    add_column :shows, :reference_source, :string
    add_column :shows, :synched_at, :datetime
    add_column :shows, :synched_by, :bigint
  end
end
