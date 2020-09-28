class AddReferenceToJobEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :job_events, :user_id, :bigint

    JobEvent.find_each do |event|
      event.update(user: Users::Admin.system) unless event.user.present?
    end
  end
end
