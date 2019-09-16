class CreateUserQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :user_queues do |t|
      t.integer :user_id
      t.integer :show_id

      t.timestamps
    end
  end
end
