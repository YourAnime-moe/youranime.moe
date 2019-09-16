FactoryBot.define do
  factory :episode do
    season_id { 1 }
    title { "MyString" }
    duration { 1.5 }
    views { 1 }
    thumbnail_url { "MyString" }
    caption_url { "MyString" }
    number { 1 }
  end
end
