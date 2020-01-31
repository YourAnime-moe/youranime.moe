class CreateRatings < ActiveRecord::Migration[6.0]
  def change
    create_table :ratings do |t|
      t.integer :show_id, null: false
      t.integer :user_id, null: false
      t.integer :value, null: false
      t.text :comment, default: ''

      t.index [:show_id, :value]
      t.index [:show_id, :user_id], unique: true

      t.timestamps
    end
  end
end
