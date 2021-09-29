class FavoritingTweet < ApplicationRecord
  #
  # ターゲットとなるツイートを取得して保存
  #
  # - 10 個保存
  # - 3 日以内に同一ユーザーからツイートがあったら保存しない (10 個以下になっちゃう)
  #
  def self.get_and_save_target_tweets(query, now)
    account = TwitterAccount.first  # TODO: アカウントをどこで決定するか
    #account = TwitterAccount.find(2)  # TODO: アカウントをどこで決定するか
    client = account.twitter_client

    tweets = client.search(query, lang: :ja)

    # TODO: 個数をどこで指定するか
    tweets.take(10).each do |t|
      # 3 日以内に同一ユーザーからツイートがあったら保存しない
      same_tweets = FavoritingTweet.where(user_screen_name: t.user.screen_name).where("tweeted_at > ?", now.ago(3.days))
      if (same_tweets.size > 0)
        next
      end

      favoriting_tweet = FavoritingTweet.find_or_initialize_by(identifier: t.id)
      if favoriting_tweet.new_record?
        favoriting_tweet.update_attributes!(
          text: t.text,
          uri: t.uri,
          user_screen_name: t.user.screen_name,
          user_uri: t.user.uri,
          user_profile_image_url: t.user.profile_image_url,
          tweeted_at: t.created_at,
          favorited: false,
        )
      end
    end
  end
end
