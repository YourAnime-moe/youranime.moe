class CreateSubscriptionTargets < ActiveRecord::Migration[7.0]
  def change
    create_table :subscription_targets do |t|
      t.belongs_to :user_subscription
      t.references :targetable, polymorphic: true
      t.string :expiry_condition, default: 'none' # eg. none, airing-ends, airing-starts, show-created, etc.

      t.timestamps
    end
  end
end
