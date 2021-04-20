# frozen_string_literal: true
class RenameShowsQueuesUsersId < ActiveRecord::Migration[6.1]
  def change
    rename_column(:shows_queues, :user_id, :graphql_user_id)
  end
end
