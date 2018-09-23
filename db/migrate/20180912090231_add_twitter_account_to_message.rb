class AddTwitterAccountToMessage < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :twitter_account, foreign_key: true
  end
end
