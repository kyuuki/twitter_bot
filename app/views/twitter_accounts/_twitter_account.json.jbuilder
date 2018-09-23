json.extract! twitter_account, :id, :account, :consumer_key, :consumer_secret, :access_token, :access_token_secret, :created_at, :updated_at
json.url twitter_account_url(twitter_account, format: :json)
