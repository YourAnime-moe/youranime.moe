class AddIsActivatedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_activated, :boolean
  end
end
