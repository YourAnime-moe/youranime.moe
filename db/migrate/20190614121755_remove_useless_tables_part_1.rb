class RemoveUselessTablesPart1 < ActiveRecord::Migration[6.0]
  def change
    drop_table :news
    drop_table :recommendations
    drop_table :messages
  end
end
