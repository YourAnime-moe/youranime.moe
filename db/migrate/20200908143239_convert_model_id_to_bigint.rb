class ConvertModelIdToBigint < ActiveRecord::Migration[6.0]
  def change
    change_column :titles, :model_id, :bigint, using: 'model_id::bigint'
    change_column :descriptions, :model_id, :bigint, using: 'model_id::bigint'
  end
end
