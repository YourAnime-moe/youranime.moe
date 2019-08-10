class CreateUserSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :user_sessions do |t|
      t.integer :user_identification, null: false
      t.string :token, null: false
      t.boolean :active, null: false, default: false
      t.datetime :active_until, null: false
      t.datetime :deleted_on

      t.index :user_identification
      t.index [:user_identification, :token]
      t.index [:active, :token]
      t.index :token, unique: true
      t.index :updated_at

      t.timestamps
    end
  end
end
