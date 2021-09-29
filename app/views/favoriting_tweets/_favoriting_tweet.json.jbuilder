json.extract! favoriting_tweet, :id, :identifier, :text, :uri, :user_screen_name, :user_uri, :user_profile_image_url, :tweet_at, :favorited, :created_at, :updated_at
json.url favoriting_tweet_url(favoriting_tweet, format: :json)
