class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :value, null: false

      t.index :value, unique: true

      t.timestamps
    end
  end
end
