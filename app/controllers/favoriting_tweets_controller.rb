class FavoritingTweetsController < ApplicationController
  before_action :set_favoriting_tweet, only: %i[ show edit update destroy ]

  # GET /favoriting_tweets or /favoriting_tweets.json
  def index
    @favoriting_tweets = FavoritingTweet.all.order(tweeted_at: :desc)
  end

  # GET /favoriting_tweets/1 or /favoriting_tweets/1.json
  def show
  end

  # GET /favoriting_tweets/new
  def new
    @favoriting_tweet = FavoritingTweet.new
  end

  # GET /favoriting_tweets/1/edit
  def edit
  end

  # POST /favoriting_tweets or /favoriting_tweets.json
  def create
    @favoriting_tweet = FavoritingTweet.new(favoriting_tweet_params)

    respond_to do |format|
      if @favoriting_tweet.save
        format.html { redirect_to @favoriting_tweet, notice: "Favoriting tweet was successfully created." }
        format.json { render :show, status: :created, location: @favoriting_tweet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @favoriting_tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /favoriting_tweets/1 or /favoriting_tweets/1.json
  def update
    respond_to do |format|
      if @favoriting_tweet.update(favoriting_tweet_params)
        format.html { redirect_to @favoriting_tweet, notice: "Favoriting tweet was successfully updated." }
        format.json { render :show, status: :ok, location: @favoriting_tweet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @favoriting_tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favoriting_tweets/1 or /favoriting_tweets/1.json
  def destroy
    @favoriting_tweet.destroy
    respond_to do |format|
      format.html { redirect_to favoriting_tweets_url, notice: "Favoriting tweet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  #
  # 検索キーワード
  #
  def keyword
    @config = Config.find_or_create_by!(key: "favorite_tweets.keyword")
  end

  def keyword_update
    # 作成されてないことはないはずだが念のため
    config = Config.find_or_create_by!(key: "favorite_tweets.keyword")

    # 簡易エラー処理
    config.update!(params.require(:config).permit(:value))

    redirect_to({ action: :keyword }, notice: "更新しました。")
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favoriting_tweet
      @favoriting_tweet = FavoritingTweet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def favoriting_tweet_params
      params.require(:favoriting_tweet).permit(:identifier, :text, :uri, :user_screen_name, :user_uri, :user_profile_image_url, :tweet_at, :favorited)
    end
end
