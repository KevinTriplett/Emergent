# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_01_10_012151) do
  create_table "memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "space_id"
    t.string "role"
    t.datetime "start_timestamp"
    t.datetime "duration_days"
    t.index ["space_id"], name: "index_memberships_on_space_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "spaces", force: :cascade do |t|
    t.string "name"
    t.string "type_of_space"
  end

  create_table "spiders", force: :cascade do |t|
    t.string "name"
    t.text "message"
    t.string "result"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "profile_url"
    t.string "chat_url"
    t.datetime "request_timestamp"
    t.datetime "join_timestamp"
    t.string "status"
    t.string "location"
    t.text "questions_responses"
    t.text "notes"
    t.string "referral"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "when_timestamp"
    t.string "first_name"
    t.string "last_name"
    t.integer "member_id"
    t.string "time_zone"
    t.string "country"
    t.string "token"
    t.string "session_token"
    t.text "change_log"
    t.integer "greeter_id"
    t.integer "shadow_greeter_id"
    t.boolean "notifications"
    t.string "roles"
    t.index ["email"], name: "index_users_on_email"
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["token"], name: "index_users_on_token", unique: true
  end

end
