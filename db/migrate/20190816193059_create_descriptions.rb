class CreateDescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :descriptions do |t|
      t.string :used_by_model
      t.string :model_id
      t.string :en
      t.string :fr
      t.string :jp

      t.index [:en, :used_by_model]
      t.index [:fr, :used_by_model]
      t.index [:jp, :used_by_model]
      t.index [:en, :fr, :jp]

      t.timestamps
    end
  end
end
