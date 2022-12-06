class CreateTweetHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :tweet_histories do |t|
      t.string :identifier
      t.text :text

      t.timestamps
    end
  end
end
