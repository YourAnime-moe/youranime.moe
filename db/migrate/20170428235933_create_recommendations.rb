class CreateRecommendations < ActiveRecord::Migration[5.0]
  def change
    create_table :recommendations do |t|
      t.string :title
      t.text :description
      t.text :plot
      t.integer :show_type
      t.boolean :dubbed
      t.string :ref_link

      t.timestamps
    end
  end
end
