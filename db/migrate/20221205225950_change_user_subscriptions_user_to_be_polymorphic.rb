class ChangeUserSubscriptionsUserToBePolymorphic < ActiveRecord::Migration[7.0]
  def change
    add_column :user_subscriptions, :user_type, :string

    UserSubscription.all.each do |us|
      user = User.find_by(id: us.user_id)
      next unless user.present?

      us.update(user_type: user.class.name)
    end
  end
end
