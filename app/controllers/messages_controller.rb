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
        format.html { redirect_to messages_path, notice: 'Message was successfully created.' }
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
        format.html { redirect_to messages_path, notice: 'Message was successfully updated.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:twitter_account_id, :category, :post_weekday, :post_time, :text, :from_at, :to_at)
    end
end
