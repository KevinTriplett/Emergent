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

ActiveRecord::Schema[7.0].define(version: 2024_01_18_173411) do
  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "space_id"
    t.string "role"
    t.datetime "start_timestamp"
    t.datetime "duration_days"
    t.index ["space_id"], name: "index_memberships_on_space_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "moderation_assessments", force: :cascade do |t|
    t.string "token"
    t.integer "state"
    t.string "url"
    t.string "original_text"
    t.string "assessment"
    t.integer "user_id"
    t.string "thread_id"
    t.string "message_id"
    t.string "run_id"
    t.string "reply"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_moderation_assessments_on_user_id"
  end

  create_table "moderations", force: :cascade do |t|
    t.string "token"
    t.string "url"
    t.string "original_text"
    t.integer "user_id"
    t.integer "moderator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reply"
    t.integer "state"
    t.datetime "state_timestamp"
    t.index ["user_id"], name: "index_moderations_on_user_id"
  end

  create_table "moderations_violations", id: false, force: :cascade do |t|
    t.integer "moderation_id", null: false
    t.integer "violation_id", null: false
  end

  create_table "notes", force: :cascade do |t|
    t.string "text"
    t.string "coords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "survey_group_id"
    t.integer "position"
    t.integer "survey_question_id"
    t.integer "z_index"
    t.index ["survey_question_id"], name: "index_notes_on_survey_question_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
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

  create_table "survey_answers", force: :cascade do |t|
    t.integer "survey_question_id"
    t.text "answer"
    t.integer "scale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "survey_invite_id"
    t.string "token"
    t.integer "vote_count"
    t.index ["survey_invite_id"], name: "index_survey_answers_on_survey_invite_id"
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
  end

  create_table "survey_groups", force: :cascade do |t|
    t.integer "survey_id"
    t.string "name"
    t.string "description"
    t.integer "votes_max"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "note_color"
    t.integer "note_style"
    t.index ["survey_id"], name: "index_survey_groups_on_survey_id"
  end

  create_table "survey_invites", force: :cascade do |t|
    t.integer "survey_id"
    t.integer "user_id"
    t.string "subject"
    t.text "body"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state"
    t.datetime "state_timestamp"
    t.string "url"
    t.boolean "enable_notes"
    t.index ["state"], name: "index_survey_invites_on_state"
    t.index ["survey_id"], name: "index_survey_invites_on_survey_id"
    t.index ["token"], name: "index_survey_invites_on_token"
    t.index ["user_id"], name: "index_survey_invites_on_user_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer "position"
    t.string "question_type"
    t.text "question"
    t.string "answer_type"
    t.boolean "has_scale"
    t.string "answer_labels"
    t.string "scale_labels"
    t.string "scale_question"
    t.integer "survey_group_id"
    t.index ["survey_group_id"], name: "index_survey_questions_on_survey_group_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "locked"
    t.boolean "live_view"
    t.boolean "liveview"
    t.string "token"
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
    t.boolean "joined"
    t.boolean "locked"
    t.boolean "approved"
    t.boolean "opt_out"
    t.index ["email"], name: "index_users_on_email"
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "violations", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.text "template"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
