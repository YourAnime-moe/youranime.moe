class AddShowIdToPosters < ActiveRecord::Migration[6.1]
  def change
    add_column :posters, :show_id, :bigint, null: false
  end
end
