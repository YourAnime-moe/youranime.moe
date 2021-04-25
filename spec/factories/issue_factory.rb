# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    open
    graphql_user
    title { 'My issue' }
    description { 'This is a sentence. ' * 100 }

    Issue::STATUSES.each do |status|
      trait(status) do
        status { status }
      end
    end
  end
end
