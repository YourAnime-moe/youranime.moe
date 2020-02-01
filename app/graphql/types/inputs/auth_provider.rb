# frozen_strin_literal: true

module Types
  module Inputs
    class AuthProvider < BaseInputObject
      graphql_name 'AuthProvider'

      argument :username, String, required: true
      argument :password, String, required: true
      # argument :fingerprint, Types::Fingerprint, required: true
    end
  end
end
