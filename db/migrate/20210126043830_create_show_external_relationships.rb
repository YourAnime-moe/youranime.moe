# frozen_string_literal: true
class CreateShowExternalRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table(:show_external_relationships) do |t|
      t.integer(:show_id, null: false)
      t.integer(:reference_id)
      t.string(:reference_source)
      t.string(:url)

      t.timestamps
    end
  end
end
