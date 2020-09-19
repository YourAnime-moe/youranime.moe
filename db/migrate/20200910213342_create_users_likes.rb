class CreateUsersLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :user_likes do |t|
      t.bigint :show_id, null: false
      t.bigint :user_id, null: false

      # value is true if it's a like, false if it's a dislike
      t.boolean :value, null: false

      # disabled is true when the user un-dis/likes the show
      t.boolean :is_disabled, null: false, default: false

      t.timestamps
    end
  end
end
