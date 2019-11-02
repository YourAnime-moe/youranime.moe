class CreateShowsQueueRelations < ActiveRecord::Migration[6.1]
  def change
    create_table :shows_queue_relations do |t|
      t.integer :show_id, null: false
      t.integer :queue_id, null: false

      t.timestamps
    end
  end
end
