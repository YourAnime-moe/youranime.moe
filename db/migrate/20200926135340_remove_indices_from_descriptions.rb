class RemoveIndicesFromDescriptions < ActiveRecord::Migration[6.0]
  def change
    remove_index :descriptions, name: "index_descriptions_on_en_and_fr_and_jp"
    remove_index :descriptions, name: "index_descriptions_on_en_and_used_by_model"
    remove_index :descriptions, name: "index_descriptions_on_fr_and_used_by_model"
    remove_index :descriptions, name: "index_descriptions_on_jp_and_used_by_model"
  end
end
