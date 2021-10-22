FactoryBot.define do
  factory :message do
    association :twitter_account
    category { 2 }
    text { "Test message." }
    from_at { 1.month.ago }
    to_at { 1.month.since }
  end
end
