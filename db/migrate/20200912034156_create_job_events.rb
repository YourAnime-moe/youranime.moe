class CreateJobEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :job_events do |t|
      t.string :status, null: false, default: :running
      t.string :job_name, null: false
      
      t.datetime :started_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :ended_at

      t.references :user, null: false, foreign_key: true
      t.bigint :job_id
      t.bigint :model_id
      t.string :used_by_model

      t.string :failed_reason_key
      t.string :failed_reason_text

      t.timestamps
    end
  end
end
