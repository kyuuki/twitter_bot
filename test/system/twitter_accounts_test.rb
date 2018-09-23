require "application_system_test_case"

class TwitterAccountsTest < ApplicationSystemTestCase
  setup do
    @twitter_account = twitter_accounts(:one)
  end

  test "visiting the index" do
    visit twitter_accounts_url
    assert_selector "h1", text: "Twitter Accounts"
  end

  test "creating a Twitter account" do
    visit twitter_accounts_url
    click_on "New Twitter Account"

    fill_in "Access Token", with: @twitter_account.access_token
    fill_in "Access Token Secret", with: @twitter_account.access_token_secret
    fill_in "Account", with: @twitter_account.account
    fill_in "Consumer Key", with: @twitter_account.consumer_key
    fill_in "Consumer Secret", with: @twitter_account.consumer_secret
    click_on "Create Twitter account"

    assert_text "Twitter account was successfully created"
    click_on "Back"
  end

  test "updating a Twitter account" do
    visit twitter_accounts_url
    click_on "Edit", match: :first

    fill_in "Access Token", with: @twitter_account.access_token
    fill_in "Access Token Secret", with: @twitter_account.access_token_secret
    fill_in "Account", with: @twitter_account.account
    fill_in "Consumer Key", with: @twitter_account.consumer_key
    fill_in "Consumer Secret", with: @twitter_account.consumer_secret
    click_on "Update Twitter account"

    assert_text "Twitter account was successfully updated"
    click_on "Back"
  end

  test "destroying a Twitter account" do
    visit twitter_accounts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Twitter account was successfully destroyed"
  end
end
