class AddCancelableToJobEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :job_events, :canceled_at, :datetime
    add_column :job_events, :canceled_by, :bigint
    add_column :job_events, :canceled_reason, :text
  end
end
