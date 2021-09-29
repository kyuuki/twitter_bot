require "application_system_test_case"

class FavoritingTweetsTest < ApplicationSystemTestCase
  setup do
    @favoriting_tweet = favoriting_tweets(:one)
  end

  test "visiting the index" do
    visit favoriting_tweets_url
    assert_selector "h1", text: "Favoriting Tweets"
  end

  test "creating a Favoriting tweet" do
    visit favoriting_tweets_url
    click_on "New Favoriting Tweet"

    check "Favorited" if @favoriting_tweet.favorited
    fill_in "Identifier", with: @favoriting_tweet.identifier
    fill_in "Text", with: @favoriting_tweet.text
    fill_in "Tweet at", with: @favoriting_tweet.tweet_at
    fill_in "Uri", with: @favoriting_tweet.uri
    fill_in "User profile image url", with: @favoriting_tweet.user_profile_image_url
    fill_in "User screen name", with: @favoriting_tweet.user_screen_name
    fill_in "User uri", with: @favoriting_tweet.user_uri
    click_on "Create Favoriting tweet"

    assert_text "Favoriting tweet was successfully created"
    click_on "Back"
  end

  test "updating a Favoriting tweet" do
    visit favoriting_tweets_url
    click_on "Edit", match: :first

    check "Favorited" if @favoriting_tweet.favorited
    fill_in "Identifier", with: @favoriting_tweet.identifier
    fill_in "Text", with: @favoriting_tweet.text
    fill_in "Tweet at", with: @favoriting_tweet.tweet_at
    fill_in "Uri", with: @favoriting_tweet.uri
    fill_in "User profile image url", with: @favoriting_tweet.user_profile_image_url
    fill_in "User screen name", with: @favoriting_tweet.user_screen_name
    fill_in "User uri", with: @favoriting_tweet.user_uri
    click_on "Update Favoriting tweet"

    assert_text "Favoriting tweet was successfully updated"
    click_on "Back"
  end

  test "destroying a Favoriting tweet" do
    visit favoriting_tweets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Favoriting tweet was successfully destroyed"
  end
end
