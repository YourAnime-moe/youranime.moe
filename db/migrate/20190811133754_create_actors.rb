class CreateActors < ActiveRecord::Migration[6.0]
  def change
    create_table :actors do |t|
      t.string :last_name
      t.string :first_name
      t.string :label

      t.timestamps
    end
  end
end
