class CreateFavoritingTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :favoriting_tweets do |t|
      t.string :identifier
      t.text :text
      t.string :uri
      t.string :user_screen_name
      t.string :user_uri
      t.string :user_profile_image_url
      t.datetime :tweeted_at
      t.boolean :favorited

      t.timestamps
    end
    add_index :favoriting_tweets, :identifier
  end
end
