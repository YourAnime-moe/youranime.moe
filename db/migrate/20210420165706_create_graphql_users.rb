# frozen_string_literal: true
class CreateGraphqlUsers < ActiveRecord::Migration[6.1]
  def change
    create_table(:graphql_users) do |t|
      t.string(:uuid, null: false)
      t.timestamps
    end
  end
end
