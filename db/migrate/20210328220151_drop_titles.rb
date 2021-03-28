# frozen_string_literal: true
class DropTitles < ActiveRecord::Migration[6.1]
  def change
    drop_table(:titles) do |t|
      t.string("used_by_model")
      t.bigint("model_id")
      t.string("en")
      t.string("fr")
      t.string("jp")
      t.string("roman", default: "taitoru", null: false)
      t.datetime("created_at", precision: 6, null: false)
      t.datetime("updated_at", precision: 6, null: false)
      t.index(["en", "fr", "jp"], name: "index_titles_on_en_and_fr_and_jp")
      t.index(["en", "used_by_model"], name: "index_titles_on_en_and_used_by_model")
      t.index(["fr", "used_by_model"], name: "index_titles_on_fr_and_used_by_model")
      t.index(["jp", "used_by_model"], name: "index_titles_on_jp_and_used_by_model")
      t.index(["roman"], name: "index_titles_on_roman")
    end
  end
end
