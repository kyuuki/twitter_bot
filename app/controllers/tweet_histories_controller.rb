class TweetHistoriesController < ApplicationController
  def index
    @tweet_histories = TweetHistory.all.order(created_at: :desc)
  end

  def delete
    tweet_history = TweetHistory.find(params[:id])

    # アカウント 1 つの前提
    account = TwitterAccount.first
    #account = TwitterAccount.find(4)

    TwitterUtil.delete(tweet_history.identifier,
                       account.consumer_key,
                       account.consumer_secret,
                       account.access_token,
                       account.access_token_secret)

    redirect_to tweet_histories_path
  end
end
