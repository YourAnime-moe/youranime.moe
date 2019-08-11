FactoryBot.define do
  factory :show do
    show_type { 1 }
    dubbed { false }
    subbed { false }
    starring { "MyString" }
    show_number { 1 }
    plot { "MyText" }
    released_on { "2019-08-11" }
    published_on { "2019-08-11" }
    featured { false }
    recommended { false }
    banner_url { "MyString" }
    en_description { "MyText" }
    fr_description { "MyText" }
    jp_description { "MyText" }
    en_title { "MyString" }
    fr_title { "MyString" }
    jp_title { "MyString" }
    roman_title { "MyString" }
  end
end
