# frozen_string_literal: true
FactoryBot.define do
  factory :rating do
    show_id { 1 }
    user_id { 1 }
    value { 1 }
    comment { "MyText" }
  end
end
