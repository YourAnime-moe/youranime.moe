class CreateUserSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_sessions do |t|
      t.integer :user_id, null: false
      t.string :user_type, null: false
      t.string :token, null: false
      t.boolean :deleted, null: false, default: false
      t.datetime :active_until, null: false
      t.datetime :deleted_on

      t.index :user_id
      t.index [:user_id, :token]
      t.index [:deleted, :token]
      t.index :token, unique: true
      t.index :updated_at

      t.timestamps
    end
  end
end
