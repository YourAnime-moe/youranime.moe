class CreateUserWatchProgresses < ActiveRecord::Migration[6.0]
  def change
    create_table :user_watch_progresses do |t|
      t.integer :user_id
      t.integer :episode_id
      t.float :progress

      t.timestamps
    end
  end
end
