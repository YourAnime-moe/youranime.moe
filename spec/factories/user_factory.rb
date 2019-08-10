# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { 'user' }
    name { 'Test User' }
    user_type { User::REGULAR }

    trait :with_email do
      email { 'test@user.com' }
    end

    trait :google do
      user_type { User::GOOGLE }
    end

    trait :admin do
      user_type { User::ADMIN }
    end
  end
end
