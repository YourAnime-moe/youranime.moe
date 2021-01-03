# frozen_string_literal: true
FactoryBot.define do
  factory :title do
    en { Faker::Book.title }
  end
end
