FactoryBot.define do
  factory(:user) do
    username { 'user' }
    name { 'Regular Account' }
    password { 'user' }
    auth_token { 'myauthtoken' }
    admin { false }

    trait :demo do
      demo { true }
    end

    trait :active do
      is_activated { true }
    end

    trait :inactive do
      is_activated { false }
    end

    trait :admin do
      admin { true }
    end
  end
end
