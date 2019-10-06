class Message < ApplicationRecord
  belongs_to :twitter_account

  validates :from_at, presence: true
  validates :to_at, presence: true

  # 表示用のモデルに変更
  # - 終了日時を前の日の 00:00 にする
  def to_view!
    self.to_at = self.to_at.yesterday unless self.to_at.nil?
  end

  # 表示用のモデルから実際のモデルに戻す
  # - 終了日時を次の日の 00:00 にする
  def from_view!
    self.to_at = self.to_at.tomorrow unless self.to_at.nil?
  end

  #
  # Twitter 投稿
  #
  def post
    account = self.twitter_account
    TwitterUtil.post(self.text,
                     account.consumer_key,
                     account.consumer_secret,
                     account.access_token,
                     account.access_token_secret)
  end
end
