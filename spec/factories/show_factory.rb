# frozen_string_literal: true
FactoryBot.define do
  factory :show do
    show_type { :anime }
    released_on { Time.now.utc }
    slug { Faker::Internet.unique.slug }
    titles do
      { en: Faker::Movie.title }
    end

    description

    trait :published do
      published { true }
    end

    trait :is_airing do
      airing_status { Show::AIRING_STATUSES.sample }
    end

    trait :is_coming_soon do
      airing_status { Show::COMING_SOON_STATUSES.sample }
    end

    trait :is_nsfw do
      nsfw { true }
    end
  end
end
