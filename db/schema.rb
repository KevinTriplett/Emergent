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

ActiveRecord::Schema[7.0].define(version: 2022_11_20_153543) do
  create_table "greeters", force: :cascade do |t|
    t.integer "member_id"
    t.string "status"
    t.integer "order_permanent"
    t.integer "order_temporary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_greeters_on_member_id"
  end

  create_table "members", force: :cascade do |t|
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
  end

end