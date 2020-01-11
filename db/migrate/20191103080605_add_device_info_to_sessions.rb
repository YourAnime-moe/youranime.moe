class AddDeviceInfoToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :device_id, :string, default: '', null: false
    add_column :user_sessions, :device_name, :string, default: '', null: false
    add_column :user_sessions, :device_location, :string, default: '', null: false
    add_column :user_sessions, :device_os, :string, default: '', null: false
    add_column :user_sessions, :device_unknown, :boolean, default: true, null: false
  end
end
