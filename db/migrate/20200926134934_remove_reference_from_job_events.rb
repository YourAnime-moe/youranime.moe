class RemoveReferenceFromJobEvents < ActiveRecord::Migration[6.0]
  def change
    remove_column :job_events, :staff_id, :bigint
  end
end
