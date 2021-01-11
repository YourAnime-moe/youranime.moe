# frozen_string_literal: true
class UpgradeTags < ActiveRecord::Migration[6.1]
  def change
    add_column(:tags, :tag_type, :string, default: 'anime', null: false)
    add_column(:tags, :ref_url, :string)
    add_column(:tags, :ref_id, :string)
  end
end
