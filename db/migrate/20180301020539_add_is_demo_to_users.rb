class AddIsDemoToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :demo, :boolean
  end
end
