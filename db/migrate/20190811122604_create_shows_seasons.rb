class CreateShowsSeasons < ActiveRecord::Migration[6.0]
  def change
    create_table :shows_seasons do |t|
      t.integer :show_id, null: false
      t.integer :number, null: false, default: 1
      t.string :name, default: ''
      t.string :banner_url

      t.index [:show_id, :number], unique: true

      t.timestamps
    end
  end
end
