class AddTaskToTrackableJob < ActiveRecord::Migration[7.0]
  def change
    add_column :job_events, :task, :string
  end
end
