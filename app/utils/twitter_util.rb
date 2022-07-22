#
# Twitter ユーティリティ
#
module TwitterUtil
  #
  # 投稿に失敗したら例外発生
  #
  def self.post(message, consumer_key, consumer_secret, access_token, access_token_secret)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = consumer_key
      config.consumer_secret     = consumer_secret
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end

    begin
      client.update!(message)
      Rails.logger.info "Twitter update '#{message}'."
    rescue => exception
      Rails.logger.fatal "Twitter update error."
      Rails.logger.info exception.message
      raise exception
    end
  end

  def self.get_media_uri_https(tweet)
    # Lint/UnreachableLoop: This loop will have at most one iteration.
    # って言われるけど、この書き方で良くない？
    # tweet.media が 0 or 1 以上で分岐しろってこと？
    tweet.media.each do |m|  # rubocop:disable Lint/UnreachableLoop
      return m.media_uri_https
    end

    nil
  end
end
