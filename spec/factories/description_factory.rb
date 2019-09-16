FactoryBot.define do
  factory :description do
    en { Faker::Lorem.paragraph_by_chars }
  end
end