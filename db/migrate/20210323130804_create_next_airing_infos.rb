# frozen_string_literal: true
class CreateNextAiringInfos < ActiveRecord::Migration[6.1]
  def change
    create_table(:next_airing_infos) do |t|
      t.references(:show)
      t.integer(:time_until_airing, null: false)
      t.datetime(:airing_at, null: false)
      t.integer(:episode_number, null: false)
      t.boolean(:past, null: false, default: true)
      t.timestamps
    end
  end
end
