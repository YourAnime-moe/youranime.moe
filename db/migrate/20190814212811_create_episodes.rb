class CreateEpisodes < ActiveRecord::Migration[6.0]
  def change
    create_table :episodes do |t|
      t.integer :season_id, null: false
      t.integer :number, null: false
      t.string :title, null: false
      t.float :duration
      t.integer :views, null: false, default: 0
      t.string :thumbnail_url
      t.string :caption_url
      t.boolean :published

      t.timestamps

      t.index [:season_id, :number], unique: true
      t.index :number
      t.index :thumbnail_url
      t.index :caption_url
    end
  end
end
