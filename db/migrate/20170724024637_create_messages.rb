class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :subject
      t.integer :from_id
      t.integer :to_id
      t.boolean :from_flag
      t.boolean :from_read
      t.boolean :to_read
      t.text :content
      t.string :icon

      t.timestamps
    end
  end
end
