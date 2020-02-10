# frozen_string_literal: true

module Mutations
  module Accounts
    class CreateSession < BaseMutation
      null true

      argument :input, Types::Inputs::AuthProvider, required: false

      field :token, String, null: true
      field :user, Types::Accounts::User, null: true

      def resolve(input: nil)
        username = input[:username]
        password = input[:password]

        user = User::Login.perform(
          username: username,
          password: password,
        )
        token = user.auth_token
        context[:session][:token] = token
        { user: user, token: token }
      rescue User::Login::LoginError => e
        Rails.logger.error(e.message)
        { error: e.message }
      end
    end
  end
end
