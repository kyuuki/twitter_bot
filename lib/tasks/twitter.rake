require 'twitter'
require 'rss'

# TODO: メソッドを別クラスに移動する？

def setup_logger
  Rails.logger = Logger.new(STDOUT)
  Rails.logger.level = Logger::DEBUG
  
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

#
# 現在時刻から投稿時刻を取得 (10 分単位)
#
# - 12:34 → 123000
# - 14:29 → 142000
#
def get_post_time_from_now(now)
  h = now.utc.hour
  m = (now.utc.min / 10) * 10  # 1 分単位切り捨て (34 → 30, 29 → 20)
  post_time = "%02d%02d00" % [h, m]

  return post_time
end

#
# 特定のカテゴリの有効なメッセージをランダムで 1 つツイート
# (メッセージの曜日や投稿時刻は参照しない)
#
# 戻り値: ツイートしたメッセージ
#
def post_random_category(now, category)
  # ツイート取得
  messages = Message.valid_category(now, category)
    
  if (messages.size == 0)
    Rails.logger.info "There is no category message."
    return nil
  end

  # ランダムに 1 つ送信
  message = messages[rand(messages.size)]
  message.post

  return message
end

#
# スケジュールに則って特定の有効なメッセージをランダムで 1 つツイート
# (メッセージの曜日や投稿時刻は参照しない)
#
# 戻り値: ツイートしたメッセージ
#
def post_random_category_by_schedule(now, category)
  # 現在時刻から取り出したい時刻を取得
  post_time = get_post_time_from_now(now)
  Rails.logger.info "post_time = #{post_time}"

  # スケジュール特定
  # 曜日と時刻でしぼる
  schedules = Schedule
                .where(category: category, post_weekday: [now.wday, nil])
                # TODO: DB に依存する部分を一カ所にまとめたい。
                .where("to_char(post_time, 'HH24MISS') = :time", { time: post_time })  # PostgreSQL
                #.where("strftime('%H%M%S', post_time) = :time", { time: post_time })  # SQLite3
  
  if (schedules.size == 0)
    Rails.logger.info "There is no schedule."
    return nil
  end

  #
  # スケジュールが存在すれば、対象のカテゴリから 1 つランダムにツイート
  #
  message = post_random_category(now, category)
  if (message == nil)
    Rails.logger.info "Post error."
    return nil
  end

  return message
end

namespace :twitter do
  #
  # スケジュールの曜日、時刻に、特定のカテゴリから 1 つをランダムツイート (10 分おき)
  #
  desc "Tweet scheduled message"
  task :scheduled_post_random, [ 'category' ] => :environment do |task, args|
    setup_logger
    
    Rails.logger.info "Task #{task.name} start."

    # 現在時刻
    now = Time.current
    Rails.logger.info "time = #{now}"
    Rails.logger.info "wday = #{now.wday}"

    # カテゴリ
    category = args.category.to_i
    Rails.logger.info "category = #{category}"

    message = post_random_category_by_schedule(now, category)
    if (message == nil)
      Rails.logger.info "Task #{task.name} failed."
      next
    end
    
    Rails.logger.info "Task #{task.name} end."
  end

  #
  # スケジュールの曜日、時刻に、特定のカテゴリから 1 つをランダムツイートして削除 (10 分おき)
  #
  desc "Tweet scheduled message and delete"
  task :scheduled_post_and_delete_random, [ 'category' ] => :environment do |task, args|
    setup_logger
    
    Rails.logger.info "Task #{task.name} start."

    # 現在時刻
    now = Time.current
    Rails.logger.info "time = #{now}"
    Rails.logger.info "wday = #{now.wday}"

    # カテゴリ
    category = args.category.to_i
    Rails.logger.info "category = #{category}"
    
    message = post_random_category_by_schedule(now, category)
    if (message == nil)
      Rails.logger.info "Task #{task.name} failed."
      next
    end

    # ツイートが成功したら削除
    message.destroy
    
    Rails.logger.info "Task #{task.name} end."
  end
  
  #
  # 特定の曜日、時刻にメッセージをツイート (10 分おき)
  #
  desc "Tweet a weekday time message"
  task :post_weekday_time, [ 'category' ] => :environment do |task, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info "Task #{task.name} start."

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    # 現在時刻
    now = Time.current
    Rails.logger.info "time = #{now}"
    Rails.logger.info "wday = #{now.wday}"

    # カテゴリ
    category = args.category.to_i
    Rails.logger.info "category = #{category}"

    # Twitter アカウント
    twitter = TwitterAccount.first
    Rails.logger.info "twitter_account = #{twitter.account}"

    # 現在時刻から取り出したい時刻を取得
    h = now.utc.hour
    m = (now.utc.min / 10) * 10  # 1 分単位切り捨て (34 → 30, 29 → 20)
    post_time = "%02d%02d00" % [h, m]
    Rails.logger.info "post_time = #{post_time}"

    # ツイート作成
    # 曜日と時刻でしぼる
    messages = Message
                 .where(twitter_account: twitter, category: category, post_weekday: now.wday)
                 .where("from_at <= :now AND :now < to_at", { now: now }).order(:id)
                 .where("to_char(post_time, 'HH24MISS') = :time", { time: post_time })  # PostgreSQL
                 #.where("time(post_time) = :time", { time: post_time })  # SQLite3

    if (messages.size == 0)
      Rails.logger.info "There is no category message."
      Rails.logger.info "Task #{task.name} failed."
      next
    end

    # 送信
    messages.each do |message|
      message.post
    end

    Rails.logger.info "Task #{task.name} end."
  end

  #
  # 特定のカテゴリから 1 つをランダムツイート
  #
  desc "Tweet a category random message"
  task :post_random, [ 'category' ] => :environment do |task, args|
    setup_logger

    Rails.logger.info "Task #{task.name} start."

    # 現在時刻
    now = Time.current
    Rails.logger.info "time = #{now}"
    Rails.logger.info "wday = #{now.wday}"

    # カテゴリ
    category = args.category.to_i
    Rails.logger.info "category = #{category}"

    #
    # 対象のカテゴリから 1 つランダムにツイート
    #
    if (post_random_category(now, category) == nil)
      Rails.logger.info "There is no category message."
      Rails.logger.info "Task #{task.name} failed."
      next
    end
    
    Rails.logger.info "Task #{task.name} end."
  end

  #
  # 特定のカテゴリメッセージをツイート (最初に一つ)
  #
  desc "Tweet a category message"
  task :post, [ 'category' ] => :environment do |task, args|
    # https://qiita.com/naoty_k/items/0be1a055932b5b461766
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info "Task #{task.name} start."

    # カテゴリ
    category = args.category.to_i
    Rails.logger.info "category = #{category}"

    # Twitter アカウント
    twitter = TwitterAccount.first
    Rails.logger.info "twitter_account = #{twitter.account}"

    # ツイート作成
    messages = Message.where(twitter_account: twitter, category: category).where("from_at <= :now AND :now < to_at", { now: Time.zone.now }).order(id: :desc)

    if (messages.size == 0)
      Rails.logger.info "There is no category message."
      Rails.logger.fatal "Task #{task.name} failed."
      next  # https://stackoverflow.com/questions/2316475/how-do-i-return-early-from-a-rake-task
    end

    message = messages[0].text
    Rails.logger.info message  # TODO: 複数行のログはどうするのがベスト？

    # 送信
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter.consumer_key
      config.consumer_secret     = twitter.consumer_secret
      config.access_token        = twitter.access_token
      config.access_token_secret = twitter.access_token_secret
    end

    begin
      client.update!(message)
    rescue => exception
      Rails.logger.info "Twitter update error."
      Rails.logger.info exception.message
      Rails.logger.fatal "Task #{task.name} failed."
      raise exception
    end

    Rails.logger.info "Task #{task.name} end."
  end

  #
  # RSS の最新記事をツイート
  #
  desc "Tweet RSS latest article"
  task :latest_rss, [ 'rss_url' ] => :environment do |task, args|
    # 基本的には不明な例外は発生しないように設計。end ログが唯一の手がかり。

    # https://qiita.com/naoty_k/items/0be1a055932b5b461766
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info "Task #{task.name} start."

    # RSS URL
    rss_url = args.rss_url
    Rails.logger.info "rss_url = #{rss_url}"

    # Twitter アカウント
    twitter = TwitterAccount.first
    if (twitter.nil?)
      Rails.logger.info "There is no TwitterAccount."
      Rails.logger.fatal "Task #{task.name} failed."
      next
    end
    Rails.logger.info "twitter_account = #{twitter.account}"

    # 最新記事取得
    begin
      rss = RSS::Parser.parse(rss_url)
    rescue => exception
      Rails.logger.info "RSS parse error."
      Rails.logger.info exception.message
      Rails.logger.fatal "Task #{task.name} failed."
      raise exception
    end

    item = rss.items[0]
    Rails.logger.debug item.title
    Rails.logger.debug item.link

    # ツイート作成
    message = "#{item.title}\n#{item.link}"
    Rails.logger.info message  # TODO: 複数行のログはどうするのがベスト？

    # 送信
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter.consumer_key
      config.consumer_secret     = twitter.consumer_secret
      config.access_token        = twitter.access_token
      config.access_token_secret = twitter.access_token_secret
    end

    begin
      client.update!(message)
    rescue => exception
      Rails.logger.info "Twitter update error."
      Rails.logger.info exception.message
      Rails.logger.fatal "Task #{task.name} failed."
      raise exception
    end

    Rails.logger.info "Task #{task.name} end."
  end

  #
  # https://news.netkeiba.com/?rf=navi スクレイピングツイート
  #
  desc "Tweet netkeiba.com"
  task :latest_news_netkeiba => :environment do |task|
    # 基本的には不明な例外は発生しないように設計。end ログが唯一の手がかり。

    # https://qiita.com/naoty_k/items/0be1a055932b5b461766
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info "Task #{task.name} start."

    # Twitter アカウント
    twitter = TwitterAccount.first
    if (twitter.nil?)
      Rails.logger.info "There is no TwitterAccount."
      Rails.logger.fatal "Task #{task.name} failed."
      next
    end
    Rails.logger.info "twitter_account = #{twitter.account}"

    # スクレイピング
    begin
      title, url = ScrapingUtil.scrape_netkeiba
    rescue => exception
      Rails.logger.info "Scraping error."
      Rails.logger.info exception.message
      Rails.logger.fatal "Task #{task.name} failed."
      raise exception
    end

    Rails.logger.debug title
    Rails.logger.debug url

    # ツイート取得 (ランダムツイート)
    messages = Message.where(twitter_account: twitter, category: 2)

    if (messages.size == 0)
      Rails.logger.info "There is no category message."
      Rails.logger.fatal "Task #{task.name} failed."
      next
    end

    message = messages[rand(messages.size)]
    
    # ツイート作成
    text = "#{title}\n\n#{message.text}\n\n#{url}"
    Rails.logger.info text

    # 送信
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter.consumer_key
      config.consumer_secret     = twitter.consumer_secret
      config.access_token        = twitter.access_token
      config.access_token_secret = twitter.access_token_secret
    end

    begin
      client.update!(text)
    rescue => exception
      Rails.logger.info "Twitter update error."
      Rails.logger.info exception.message
      Rails.logger.fatal "Task #{task.name} failed."
      raise exception
    end

    Rails.logger.info "Task #{task.name} end."
  end
end
