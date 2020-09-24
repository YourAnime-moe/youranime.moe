class AddTypeToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :type, :string

    User.find_each do |user|
      user.update!(type: Users::Regular.name)
    end

    change_column :users, :type, :string, null: false
  end

  def down
    remove_column :users, :type, :string
  end
end
