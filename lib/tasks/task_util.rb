#
# タスク用ユーティリティ
#
module TaskUtil
  # TODO: ログレベルはどこで指定する？
  def setup_logger
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end
