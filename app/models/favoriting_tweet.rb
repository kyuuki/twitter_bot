class FavoritingTweet < ApplicationRecord
  #
  # ターゲットとなるツイートを取得して保存
  #
  # - 10 個保存
  # - 3 日以内に同一ユーザーからツイートがあったら保存しない (10 個以下になっちゃう)
  #
  def self.get_and_save_target_tweets(query, now)
    account = TwitterAccount.first  # TODO: アカウントをどこで決定するか
    #account = TwitterAccount.find(2)
    client = account.twitter_client

    tweets = client.search(query, lang: :ja)

    # TODO: 個数をどこで指定するか
    tweets.take(10).each do |t|
      # 3 日以内に同一ユーザーからツイートがあったら保存しない
      same_tweets = FavoritingTweet.where(user_screen_name: t.user.screen_name).where("tweeted_at > ?", now.ago(3.days))
      if same_tweets.size > 0
        next
      end

      favoriting_tweet = FavoritingTweet.find_or_initialize_by(identifier: t.id)
      if favoriting_tweet.new_record?
        favoriting_tweet.update_attributes!(
          text: t.text,
          uri: t.uri,
          user_screen_name: t.user.screen_name,
          user_uri: t.user.uri,
          #user_profile_image_url: TwitterUtil.get_media_uri_https(t).presence || t.user.profile_image_url,
          user_profile_image_url: t.user.profile_image_url,
          tweeted_at: t.created_at,
          favorited: false,
        )
      end
    end
  end

  #
  # 最新の数件をお気に入り
  #
  def self.favorite!(account_id, count)
    if count <= 0
      raise ArgumentError, "count = #{count}"
    end

    if account_id.nil?
      account = TwitterAccount.first
    else
      account = TwitterAccount.find(account_id)
    end
    client = account.twitter_client

    logger.info "TwitterAccout = #{account.account}"

    tweets = FavoritingTweet.where(favorited: false).order(tweeted_at: :asc)
    tweet_ids = tweets[0..count - 1].map(&:identifier)
    logger.info "tweet_ids = #{tweet_ids}"

    client.favorite!(tweet_ids)

    # お気に入り済みに TODO: 本当はトランザクション
    tweets[0..count - 1].each do |t|
      t.favorited = true
      t.save
    end
  end
end
