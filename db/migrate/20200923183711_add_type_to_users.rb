class AddTypeToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :type, :string

    User.find_each do |user|
      backfill_user_by_type(user)
    end

    change_column :users, :type, :string, null: false
  end

  def down
    remove_column :users, :type, :string
  end

  def backfill_user_by_type(user)
    klass_name = if user.staff_user.present?
      Users::Admin
    elsif user.user_type == 'google'
      Users::Google
    elsif user.user_type == 'misete'
      Users::Misete
    else
      Users::Regular
    end
    user.update!(type: klass_name.name)
  end
end
