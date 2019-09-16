# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { 'user' }
    name { 'Test User' }
    user_type { User::REGULAR }

    trait :with_email do
      email { 'test@user.com' }
    end
  end
end
