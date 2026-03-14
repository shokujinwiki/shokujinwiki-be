FactoryBot.define do
  factory :user do
    name { "John Doe" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
  end
end
