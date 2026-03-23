FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password123!" }
    password_confirmation { "Password123!" }

    # if already linked todoist
    trait :with_todoist do
      todoist_access_token { "mock_access_token_#{SecureRandom.hex(10)}" }
    end
  end
end
