class CreateExternalConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :external_connections do |t|
      t.string :connection_type, null: false
      t.string :connection_user_id, null: false
      t.string :access_token
      t.string :refresh_token
      t.datetime :access_token_expiry
      t.datetime :refresh_token_expiry

      t.timestamps
    end
  end
end
