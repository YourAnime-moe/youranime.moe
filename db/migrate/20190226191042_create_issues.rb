class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.boolean :resolved
      t.boolean :open
      t.string :page_url
      t.text :screenshots

      t.timestamps
    end
  end
end
