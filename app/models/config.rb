class Config < ApplicationRecord
  KEY_FAVORITE_TWEETS_KEYWORD = "favorite_tweets.keyword"
  KEY_PERIODICAL_MINUTE = "periodical.minute"

  validates :value, numericality: { only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 99999 }, if: :is_periodical_minute?

  def is_periodical_minute?
    key == KEY_PERIODICAL_MINUTE
  end

  #
  # 定期ツイート間隔 (秒) 取得
  #
  # 戻り値: Integer or nil
  #
  def self.get_periodical_minute
    config = Config.find_by(key: KEY_PERIODICAL_MINUTE)
    if config.nil?
      logger.error "There is no config of #{KEY_PERIODICAL_MINUTE}"
      return nil
    end

    if config.invalid?
      logger.fatal "Config is invalid."
      return nil
    end

    # バリデーションは通っている前提
    config.value.to_i
  end
end
