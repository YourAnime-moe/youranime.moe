# frozen_string_literal: true

FactoryBot.define do
  factory :users_session, class: 'Users::Session' do
    user
    active
    token { SecureRandom.hex }

    trait :deleted do
      deleted { true }
      active_until { Time.now.utc }
      deleted_on { active_until }
    end

    trait :active do
      deleted { false }
      active_until { 1.day.from_now.utc }
    end
  end
end
