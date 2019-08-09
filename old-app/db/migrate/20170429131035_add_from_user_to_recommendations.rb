class AddFromUserToRecommendations < ActiveRecord::Migration[5.0]
  def change
    add_column :recommendations, :from_user, :integer
  end
end
