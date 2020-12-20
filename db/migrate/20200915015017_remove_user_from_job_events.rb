class RemoveUserFromJobEvents < ActiveRecord::Migration[6.0]
  def change
    remove_reference :job_events, :user, null: false, foreign_key: true
    add_reference :job_events, :staff, null: false, index: true, foreign_key: true, default: 0
  end
end
