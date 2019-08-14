FactoryBot.define do
  factory :show do
    show_type { :anime }
    released_on { Time.now.utc }

    plot do
      "This anime is about this girl and this guy."
    end

    trait :published do
      published_on { 1.year.ago }
    end
  end
end