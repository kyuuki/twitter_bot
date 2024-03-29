class PeriodicalController < ApplicationController
  #
  # 定期実行の周期 (分)
  #
  def minute
    # ↓これだとデータがない場合にバリデーションに引っかかる
    #@config = Config.find_or_create_by!(key: "periodical.minute")
    @config = Config.find_or_create_by!(key: "periodical.minute") do |config|
      config.value = "10"
    end
  end

  def minute_update
    # 作成されてないことはないはずだが念のため
    @config = Config.find_or_create_by!(key: "periodical.minute") do |config|
      config.value = "10"
    end

    if @config.update(params.require(:config).permit(:value))
      redirect_to({ action: :minute }, notice: "更新しました。")
    else
      # TODO: 本来は別フォームでバリデーションをかけるのが正しい気がする。
      # エラーメッセージの項目名がおかしいのは許容する
      render :minute
    end
  end
end
