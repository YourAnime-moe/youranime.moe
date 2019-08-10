class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, null: false, unique: true
      t.string :identification, null: false, unique: true
      t.string :name, null: false
      t.string :email, unique: true
      t.integer :user_type, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :limited, null: false, default: true
      
      t.index :username, unique: true
      t.index [:username, :email]
      t.index :updated_at

      t.timestamps
    end
  end
end
