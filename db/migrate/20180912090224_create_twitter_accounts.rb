class CreateTwitterAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :twitter_accounts do |t|
      t.string :account
      t.string :consumer_key
      t.string :consumer_secret
      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end
  end
end
