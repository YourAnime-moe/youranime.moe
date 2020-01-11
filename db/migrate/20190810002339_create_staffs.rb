class CreateStaffs < ActiveRecord::Migration[6.0]
  def change
    create_table :staffs do |t|
      t.string :username, null: false, unique: true
      t.string :identification, null: false, unique: true
      t.string :name, null: false
      t.string :user_type, null: false, default: 'staff'
      t.string :password_digest
      t.boolean :active, null: false, default: true
      t.boolean :limited, null: false, default: true
      t.integer :user_id

      t.timestamps
    end
  end
end
