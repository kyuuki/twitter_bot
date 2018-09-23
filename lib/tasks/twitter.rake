require 'twitter'

namespace :twitter do
  desc "Tweet kanken question"
  task :post, [ 'category' ] => :environment do |task, args|
    # https://qiita.com/naoty_k/items/0be1a055932b5b461766
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info "Task twitter:post start."

    # Twitter アカウント
    twitter = TwitterAccount.first
    Rails.logger.info "twitter_account = #{twitter.account}"
    
    # カテゴリ
    category = args.category.to_i
    Rails.logger.info "category = #{category}"

    messages = Message.where(twitter_account: twitter, category: category).where("from_at <= :now AND :now < to_at", { now: Time.zone.now }).order(id: :desc)

    if (messages.size == 0)
      Rails.logger.info "Task twitter:post no message."
      next  # https://stackoverflow.com/questions/2316475/how-do-i-return-early-from-a-rake-task
    end
    
    message = messages[0]
    Rails.logger.info "message = #{message.text}."

    begin
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = twitter.consumer_key
        config.consumer_secret     = twitter.consumer_secret
        config.access_token        = twitter.access_token
        config.access_token_secret = twitter.access_token_secret
      end

      client.update(message.text)
    rescue => exception
      Rails.logger.fatal "Task twitter:post failed."
      Rails.logger.info exception.message
      raise exception
    end

    Rails.logger.info "Task twitter:post end."
  end
end
