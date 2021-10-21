require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    @message = FactoryBot.create(:message)

    @admin_user = FactoryBot.create(:admin_user)
    login_as(@admin_user)
  end

  test "should get index" do
    get messages_url
    assert_response :success
  end

  test "should get new" do
    get new_message_url
    assert_response :success
  end

  test "should create message" do
    assert_difference('Message.count') do
      post messages_url, params: { message: { category: @message.category, from_at: @message.from_at, text: @message.text, to_at: @message.to_at, twitter_account_id: @message.twitter_account_id } }
    end

    assert_redirected_to messages_url
  end

  test "should show message" do
    get message_url(@message)
    assert_response :success
  end

  test "should get edit" do
    get edit_message_url(@message)
    assert_response :success
  end

  test "should update message" do
    patch message_url(@message), params: { message: { category: @message.category, from_at: @message.from_at, text: @message.text, to_at: @message.to_at } }
    assert_redirected_to messages_url
  end

  test "should destroy message" do
    assert_difference('Message.count', -1) do
      delete message_url(@message)
    end

    assert_redirected_to messages_url
  end
end
