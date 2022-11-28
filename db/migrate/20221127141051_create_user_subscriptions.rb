class CreateUserSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_subscriptions do |t|
      t.belongs_to :user
      t.string :subscription_type, null: false      # what the user want to be notified of (eg. new airing ep)
      t.string :platform, null: false               # where the notification is sent to (eg. discord, mobile app)
      t.string :platform_user_id                    # if applicable, the user's id on the platform

      t.timestamps
    end
  end
end
