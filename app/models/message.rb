class Message < ApplicationRecord
  belongs_to :twitter_account

  validates :from_at, presence: true
  validates :to_at, presence: true

  with_options if: :category_is_week? do
    validates :post_weekday, presence: true
    validates :post_time, presence: true
  end

  # 有効かどうかは 10 分ごとの値でなくリアルタイムの現在時刻をベースにする。
  scope :valid, ->(now) { where("from_at <= :now AND :now < to_at", { now: now }) }
  scope :valid_category, ->(now, category) { valid(now).where(category: category) }

  def category_is_week?
    self.category == 1
  end

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

  # カテゴリが曜日とランダム用
  def modify_for_weekday_and_random!
    if self.category == 2
      self.post_weekday = nil
      self.post_time = nil
    end
  end

  # 期間を無制限に
  def set_at_unlimited!
    self.from_at = "1970-01-01"
    self.to_at = "2100-12-31"
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
