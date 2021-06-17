class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.order(:category, :post_weekday, :id)
    # ↓SQLite 専用
    #@messages = Message.order(:category, :post_weekday).order("time(post_time, '+9 hours')")
    # ↓PostgreSQL 専用
    #@messages = Message.order(:category, :post_weekday).order("post_time AT TIME ZONE 'Japan'").order(:text)
    @messages.map {|message| message.to_view!}
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
    @message.twitter_account = TwitterAccount.first
    #@message.from_at = "0000-01-01"
    #@message.to_at = "9999-01-01"
  end

  # GET /messages/1/edit
  def edit
    @message.to_view!
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)
    @message.from_view!
    @message.modify_for_weekday_and_random!

    respond_to do |format|
      if @message.save
        format.html { redirect_to messages_url, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    @message.assign_attributes(message_params)
    @message.from_view!
    @message.modify_for_weekday_and_random!

    respond_to do |format|
      if @message.save
        format.html { redirect_to messages_url, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def upload_new
  end
  
  def upload
    upload_file = params[:file]
    
    if upload_file.nil?
      flash.now[:alert] = "ファイルを選択してください。"
      render :upload_new
      return
    end
    
    twitter_account = TwitterAccount.first

    # TODO: トランザクション
    # TODO: エラー処理
    
    # Excel で 1 行目が複数行の CSV を出力するとエラー。どうやっても解消できず。
    # ヘッダを改行なしで入れるルールにしておく。
    csv = Roo::CSV.new(upload_file.path,
                       csv_options: {
                         headers: true,
                         skip_blanks: true,
                       })

    begin
      ActiveRecord::Base.transaction do
        delete_all_and_create_from_csv(twitter_account, csv)
      end
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "システムでエラーが発生しました。"
      render :upload_new
      return
    rescue CSV::MalformedCSVError => e
      # CSV 不正
      flash.now[:alert] = "CSV ファイル読み込みでエラーが発生しました。"
      render :upload_new
      return
    end
    
    redirect_to messages_url, notice: 'アップロードが完了しました。'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:twitter_account_id, :category, :post_weekday, :post_time, :text, :from_at, :to_at)
    end

    def delete_all_and_create_from_csv(twitter_account, csv)
      # メッセージ全削除
      # Message.delete_all はよろしくないので下の方法に。
      # https://qiita.com/hiroki_tanaka/items/9ab7eb532fb71e83ffb6
      messages = Message.all
      messages.in_batches.each do |delete_messages|
        delete_messages.map(&:destroy!)
        sleep(0.1)
      end

      csv.each do |row|
        text = row[0][1]  # headers: true にすると row[0] は ["text(見出し)","..."] みたいな形になる。微妙。。。
        message = Message.new(
          twitter_account: twitter_account,
          category: 3,
          text: text,
        )
        message.set_at_unlimited!
        message.save!
      end
    end
end
