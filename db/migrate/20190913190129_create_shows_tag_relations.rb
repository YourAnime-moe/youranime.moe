class CreateShowsTagRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :shows_tag_relations do |t|
      t.integer :show_id
      t.integer :tag_id

      t.index [:show_id, :tag_id], unique: true

      t.timestamps
    end
  end
end
