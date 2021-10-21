FactoryBot.define do
  factory :twitter_account do
    account { "kyuuki0" }
    consumer_key { "000consumer_key" }
    consumer_secret { "111consumer_secret" }
    access_token { "222access_token" }
    access_token_secret { "333access_token_secret" }
  end
end
