FactoryBot.define do
  factory :review do
    content { "My review" }
    user
  end
end
