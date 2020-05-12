class CreateUserSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_sessions do |t|
      t.integer :user_id, null: false
      t.string :user_type, null: false
      t.string :token, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :active_until, null: false
      t.datetime :deleted_on

      t.string :device_id, default: "", null: false
      t.string :device_name, default: "", null: false
      t.string :device_location, default: "", null: false
      t.string :device_os, default: "", null: false
      t.boolean :device_unknown, default: true, null: false

      t.index :user_id
      t.index [:user_id, :token]
      t.index [:deleted, :token]
      t.index :token, unique: true
      t.index :updated_at

      t.timestamps
    end
  end
end
