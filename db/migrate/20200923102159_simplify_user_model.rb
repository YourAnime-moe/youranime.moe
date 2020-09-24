class SimplifyUserModel < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :first_name, :string, null: false, default: ''
    add_column :users, :last_name, :string

    User.find_each do |user|
      next unless user.name.present?

      first_name = user.name.split(' ')[0]
      last_name = user.name.split(' ')[1]

      user.update(first_name: first_name, last_name: last_name)
    end

    remove_column :users, :name, :string

    rename_column :users, :google_token, :oauth_token
    rename_column :users, :google_refresh_token, :oauth_refresh_token
  end

  def down
    add_column :users, :name, :string

    User.find_each do |user|
      user.update(name: "#{user.first_name} #{user.last_name}")
    end

    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string

    rename_column :users, :oauth_token, :google_token
    rename_column :users, :oauth_refresh_token, :google_refresh_token
  end
end
