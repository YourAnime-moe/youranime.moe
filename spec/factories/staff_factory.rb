# frozen_string_literal: true

FactoryBot.define do
  factory :staff do
    username { 'staff' }
    password { 'password' }
    name { 'Test Staff' }
    user_type { Staff::REGULAR }
  end
end
