# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_27_164626) do

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.integer "category"
    t.string "text"
    t.datetime "from_at"
    t.datetime "to_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "twitter_account_id"
    t.integer "post_weekday"
    t.time "post_time"
    t.index ["twitter_account_id"], name: "index_messages_on_twitter_account_id"
  end

  create_table "twitter_accounts", force: :cascade do |t|
    t.string "account"
    t.string "consumer_key"
    t.string "consumer_secret"
    t.string "access_token"
    t.string "access_token_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
