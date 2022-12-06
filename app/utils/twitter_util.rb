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

  #
  # Twitter API v2 対応
  #
  # - Faraday を利用
  # - https://github.com/yhara/simple_twitter/blob/main/lib/simple_twitter.rb を参考に
  #
  def self.post_v2(message, consumer_key, consumer_secret, access_token, access_token_secret)
    connection = Faraday.new do |conn|
      conn.request(:oauth,
                   consumer_key: consumer_key,
                   consumer_secret: consumer_secret,
                   token: access_token,
                   token_secret: access_token_secret)

      conn.request(:json)
      conn.response(:json)
    end

    response = connection.post("https://api.twitter.com/2/tweets",
                               { text: message },
                               "Content-Type" => "application/json")

    if (response.status / 100 == 2)
      Rails.logger.info "Twitter update '#{message}'."
      Rails.logger.debug "#{response.body}"
      Rails.logger.info "id = #{response.body["data"]["id"]}."

      # ツイート履歴保存
      TweetHistory.create(identifier: response.body["data"]["id"], text: message)
    else
      Rails.logger.fatal "Twitter update error."
      Rails.logger.info response.body
      raise "Twitter update error."
    end
  end

  def self.delete(id, consumer_key, consumer_secret, access_token, access_token_secret)
    connection = Faraday.new do |conn|
      conn.request(:oauth,
                   consumer_key: consumer_key,
                   consumer_secret: consumer_secret,
                   token: access_token,
                   token_secret: access_token_secret)

      conn.request(:json)
      conn.response(:json)
    end

    response = connection.delete("https://api.twitter.com/2/tweets/#{id}",
                                 {},
                                 "Content-Type" => "application/json")

    if (response.status / 100 == 2)
      Rails.logger.info "Twitter delete '#{id}'."
      Rails.logger.debug "#{response.body}"
      #Rails.logger.info "id = #{response.body["data"]["id"]}."
    else
      Rails.logger.fatal "Twitter delete error."
      Rails.logger.info response.body
      raise "Twitter delete error."
    end
  end
end
