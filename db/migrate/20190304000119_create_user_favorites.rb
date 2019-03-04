class CreateUserFavorites < ActiveRecord::Migration[6.0]
  def change
    create_table :user_favorites do |t|
      t.integer :show_id
      t.integer :user_id

      t.timestamps
    end
  end
end
