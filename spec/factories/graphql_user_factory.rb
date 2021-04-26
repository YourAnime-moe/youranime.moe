# frozen_string_literal: true

FactoryBot.define do
  factory :graphql_user, class: 'GraphqlUser' do
    uuid { SecureRandom.uuid }
  end
end
