FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "attendee" }

    trait :organizer do
      role { "organizer" }
    end

    trait :admin do
      role { "admin" }
    end
  end
end
