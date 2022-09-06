class AddBacktraceAndChangeJobIdFieldForJobEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :job_events, :backtrace, :text
    change_column :job_events, :job_id, :string
  end
end
