class Message < ApplicationRecord
  UNLIMITED_FORM_AT = Time.zone.parse("1970-01-01 00:00:00")
  UNLIMITED_TO_AT = Time.zone.parse("2101-01-01 00:00:00")

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
    if self.from_at == UNLIMITED_FORM_AT
      self.from_at = nil
    end

    if self.to_at == UNLIMITED_TO_AT
      self.to_at = nil
    else
      self.to_at = self.to_at.yesterday
    end
  end

  # 表示用のモデルから実際のモデルに戻す
  # - 終了日時を次の日の 00:00 にする
  def from_view!
    if self.from_at.nil?
      self.from_at = UNLIMITED_FORM_AT
    end

    if self.to_at.nil?
      self.to_at = UNLIMITED_TO_AT
    else
      self.to_at = self.to_at.tomorrow
    end
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
    self.from_at = UNLIMITED_FORM_AT
    self.to_at = UNLIMITED_TO_AT
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
