class ChangeEnDescriptionType < ActiveRecord::Migration[6.0]
  def change
    change_column :shows, :en_description, :text
  end
end
