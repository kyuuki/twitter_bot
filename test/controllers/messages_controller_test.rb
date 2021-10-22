require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    @message = FactoryBot.create(:message)

    @admin_user = FactoryBot.create(:admin_user)
    login_as(@admin_user)
  end

  test "should get index" do
    Message.delete_all  # setup で作ってしまってるデータを削除 (微妙)
    messages = FactoryBot.create_list(:message, 10)

    get messages_url

    assert_response :success

    #
    # 画面要素
    #
    # 各メッセージのデータ
    # TODO: テーブルじゃなくなる可能性も多い？
    assert_select "table.table tbody tr", count: 10

    # 最初の項目
    assert_select "table.table tbody tr:nth-child(1)" do
      assert_select "td:first-child", messages[0].id.to_s  # ID 順だと 0 番目が一番上？
      assert_select "td", /ランダム/  # ID 以外は td タグの順序は問わない
      assert_select "td", /Test message./
      # TODO: 開始日と終了日は固定にしておかないとテストしにくい

      # 編集ボタン
      assert_select "a[href=?]", edit_message_path(messages[0])

      # 削除ボタン
      assert_select "a[href=?][data-method=delete]", message_path(messages[0])
    end

    # 最後の項目
    assert_select "table.table tbody tr:nth-child(10)" do
      assert_select "td:first-child", messages[9].id.to_s
      assert_select "td", /ランダム/  # ID 以外は td タグの順序は問わない
      assert_select "td", /Test message./
      # TODO: 開始日と終了日は固定にしておかないとテストしにくい
    end

    # 並び順は ID の値で行っている

    # 新規登録ボタン (上下 2 つ)
    # TODO: button タグになる可能性も多い？
    assert_select "a[href=?]", new_message_path, count: 2

    # アップロードボタン
    assert_select "a[href=?]", upload_new_messages_path, count: 2

    # TODO: メッセージが多くなった場合はページングのテストも？
    # Twitter ボットにはページングがない
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
