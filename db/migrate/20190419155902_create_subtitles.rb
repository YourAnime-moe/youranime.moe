class CreateSubtitles < ActiveRecord::Migration[6.0]
  def change
    create_table :subtitles do |t|
      t.integer :episode_id
      t.string :name
      t.string :lang
      t.boolean :default

      t.timestamps
    end
    add_index :subtitles, [:episode_id, :lang]
  end
end
