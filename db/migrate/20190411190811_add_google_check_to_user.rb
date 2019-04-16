class AddGoogleCheckToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :google_user, :boolean, default: false, null: false
  end
end
