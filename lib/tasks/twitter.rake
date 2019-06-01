require 'twitter'
require 'rss'

namespace :twitter do
  #
  # 特定のカテゴリメッセージをツイート
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
      client.update(message)
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
      client.update(message)
    rescue => exception
      Rails.logger.info "Twitter update error."
      Rails.logger.info exception.message
      Rails.logger.fatal "Task #{task.name} failed."
      raise exception
    end

    Rails.logger.info "Task #{task.name} end."
  end
end
