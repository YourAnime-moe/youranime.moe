class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :identification, null: false
      t.string :name, null: false
      t.string :email
      t.string :user_type, null: false, default: 'regular'
      t.boolean :active, null: false, default: true
      t.boolean :limited, null: false, default: true
      t.boolean :google_user, null: false, default: false
      t.string :hex, null: false, default: '#000000'
      t.string :google_token
      t.string :google_refresh_token
      t.string :password_digest
      
      t.index :username, unique: true
      t.index :email, unique: true
      t.index :identification, unique: true
      t.index :hex, unique: true
      t.index [:username, :email]
      t.index :google_token
      t.index :google_refresh_token
      t.index :updated_at

      t.timestamps
    end
  end
end
