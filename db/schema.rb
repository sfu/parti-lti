# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151127214854) do

  create_table "lti_tool_consumer_tokens", force: :cascade do |t|
    t.integer "lti_tool_consumer_id"
    t.integer "user_id"
    t.string  "token"
    t.string  "refresh_token"
    t.integer "expires_at"
  end

  add_index "lti_tool_consumer_tokens", ["lti_tool_consumer_id"], name: "index_lti_tool_consumer_tokens_on_lti_tool_consumer_id"
  add_index "lti_tool_consumer_tokens", ["user_id"], name: "index_lti_tool_consumer_tokens_on_user_id"

  create_table "lti_tool_consumers", force: :cascade do |t|
    t.string "name"
    t.string "oauth_consumer_key"
    t.string "oauth_shared_secret"
    t.string "product_family"
    t.string "url_root"
    t.string "oauth2_auth_request_path"
    t.string "oauth2_token_request_path"
    t.string "oauth2_client_id"
    t.string "oauth2_client_secret"
  end

  add_index "lti_tool_consumers", ["oauth_consumer_key"], name: "index_lti_tool_consumers_on_oauth_consumer_key", unique: true

  create_table "participants", force: :cascade do |t|
    t.string   "role"
    t.integer  "user_id"
    t.integer  "room_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "grade_passback_id"
  end

  add_index "participants", ["room_id"], name: "index_participants_on_room_id"
  add_index "participants", ["user_id"], name: "index_participants_on_user_id"

  create_table "pseudonyms", force: :cascade do |t|
    t.string   "service"
    t.string   "identifier"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "pseudonyms", ["user_id"], name: "index_pseudonyms_on_user_id"

  create_table "rooms", force: :cascade do |t|
    t.string   "name"
    t.boolean  "open"
    t.datetime "start_at"
    t.datetime "finish_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "lti_tool_name"
    t.string   "lti_url_root"
    t.string   "lti_resource_link_id"
    t.string   "lti_context_type"
    t.string   "lti_context_id"
    t.string   "lti_oauth_consumer_key"
    t.string   "grade_passback_url"
    t.integer  "lti_tool_consumer_id"
    t.integer  "max_rating",             default: 4
  end

  add_index "rooms", ["lti_tool_consumer_id"], name: "index_rooms_on_lti_tool_consumer_id"

  create_table "submissions", force: :cascade do |t|
    t.integer  "rating",             default: -1
    t.boolean  "show",               default: false
    t.boolean  "flagged",            default: false
    t.integer  "participant_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "starred",            default: false
  end

  add_index "submissions", ["participant_id"], name: "index_submissions_on_participant_id"

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "email",              default: "", null: false
    t.string   "encrypted_password", default: "", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
