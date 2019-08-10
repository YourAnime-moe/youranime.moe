class CreateShowsQueues < ActiveRecord::Migration[6.1]
  def change
    create_table :shows_queues do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
