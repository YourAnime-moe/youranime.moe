class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :issues do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :status, null: false
      t.string :page_url
      t.integer :user_id, null: false
      t.datetime :closed_on

      t.index :title
      t.index :user_id
      t.index :closed_on

      t.timestamps
    end
  end
end
