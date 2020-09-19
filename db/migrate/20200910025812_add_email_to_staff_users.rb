class AddEmailToStaffUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :staffs, :email, :string
  end
end
