FactoryBot.define do
  factory :show do
    show_type { :anime }
    released_on { Time.now.utc }
    
    description
    title

    trait :published do
      published { true }
    end
  end
end