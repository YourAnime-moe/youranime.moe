class CreateShowUrls < ActiveRecord::Migration[6.0]
  def change
    create_table :show_urls do |t|
      t.string :url_type, null: false
      t.string :value, null: false
      t.references :show, null: false, foreign_key: true

      t.timestamps
    end
  end
end
