class CreateStaffs < ActiveRecord::Migration[6.1]
  def change
    create_table :staffs do |t|
      t.string :username, null: false, unique: true
      t.string :identification, null: false, unique: true
      t.string :name, null: false
      t.integer :user_type, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :limited, null: false, default: true
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
