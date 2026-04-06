FactoryBot.define do
  factory :event do
    association :user, factory: :user, role: "organizer"
    title { "Sample Event" }
    description { "Event description" }
    venue { "Test Venue" }
    starts_at { 1.week.from_now }
    ends_at { 1.week.from_now + 2.hours }
    category { "conference" }
    status { "published" }
  end
end
