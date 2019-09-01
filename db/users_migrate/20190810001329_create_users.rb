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
      t.string :hex, null: false, default: '#000000'
      
      t.index :username, unique: true
      t.index :email, unique: true
      t.index :identification, unique: true
      t.index :hex, unique:, true
      t.index [:username, :email]
      t.index :updated_at

      t.timestamps
    end
  end
end
