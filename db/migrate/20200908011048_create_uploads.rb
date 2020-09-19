class CreateUploads < ActiveRecord::Migration[6.0]
  def change
    create_table :uploads do |t|
      t.references :user, foreign_key: true

      t.string :uuid, null: false
      t.string :upload_type, null: false
      t.string :upload_status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
