# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_16_215724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "actors", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "label"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "descriptions", force: :cascade do |t|
    t.string "used_by_model"
    t.bigint "model_id"
    t.string "en"
    t.string "fr"
    t.string "jp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["en", "fr", "jp"], name: "index_descriptions_on_en_and_fr_and_jp"
    t.index ["en", "used_by_model"], name: "index_descriptions_on_en_and_used_by_model"
    t.index ["fr", "used_by_model"], name: "index_descriptions_on_fr_and_used_by_model"
    t.index ["jp", "used_by_model"], name: "index_descriptions_on_jp_and_used_by_model"
  end

  create_table "episodes", force: :cascade do |t|
    t.integer "season_id", null: false
    t.integer "number", null: false
    t.string "title", null: false
    t.float "duration"
    t.integer "views", default: 0, null: false
    t.string "thumbnail_url"
    t.string "caption_url"
    t.boolean "published"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["caption_url"], name: "index_episodes_on_caption_url"
    t.index ["number"], name: "index_episodes_on_number"
    t.index ["season_id", "number"], name: "index_episodes_on_season_id_and_number", unique: true
    t.index ["thumbnail_url"], name: "index_episodes_on_thumbnail_url"
  end

  create_table "issues", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "status", null: false
    t.string "page_url"
    t.integer "user_id", null: false
    t.datetime "closed_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["closed_on"], name: "index_issues_on_closed_on"
    t.index ["title"], name: "index_issues_on_title"
    t.index ["user_id"], name: "index_issues_on_user_id"
  end

  create_table "job_events", force: :cascade do |t|
    t.string "status", default: "running", null: false
    t.string "job_name", null: false
    t.datetime "started_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "ended_at"
    t.bigint "job_id"
    t.bigint "model_id"
    t.string "used_by_model"
    t.string "failed_reason_key"
    t.string "failed_reason_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "staff_id", null: false
    t.index ["staff_id"], name: "index_job_events_on_staff_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "user_id", null: false
    t.integer "value", null: false
    t.text "comment", default: ""
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id", "user_id"], name: "index_ratings_on_show_id_and_user_id", unique: true
    t.index ["show_id", "value"], name: "index_ratings_on_show_id_and_value"
  end

  create_table "shows", force: :cascade do |t|
    t.string "show_type", default: "anime", null: false
    t.boolean "dubbed", default: false, null: false
    t.boolean "subbed", default: true, null: false
    t.boolean "published", default: false, null: false
    t.integer "views", default: 0, null: false
    t.integer "popularity", default: -1, null: false
    t.float "rating", default: 0.0, null: false
    t.text "plot", default: "", null: false
    t.date "released_on", null: false
    t.date "published_on"
    t.boolean "featured", default: false, null: false
    t.boolean "recommended", default: false, null: false
    t.string "banner_url", default: "/img/404.jpg", null: false
    t.integer "queue_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "reference_id"
    t.string "reference_source"
    t.datetime "synched_at"
    t.bigint "synched_by"
    t.integer "likes_count", default: 0, null: false
    t.integer "dislikes_count", default: 0, null: false
    t.integer "loves_count", default: 0, null: false
    t.string "poster_url", default: "/img/404.jpg", null: false
    t.index ["banner_url"], name: "index_shows_on_banner_url"
  end

  create_table "shows_queue_relations", force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "queue_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shows_queues", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shows_seasons", force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "number", default: 1, null: false
    t.string "name", default: ""
    t.string "banner_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id", "number"], name: "index_shows_seasons_on_show_id_and_number", unique: true
  end

  create_table "shows_tag_relations", force: :cascade do |t|
    t.integer "show_id"
    t.integer "tag_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id", "tag_id"], name: "index_shows_tag_relations_on_show_id_and_tag_id", unique: true
  end

  create_table "staffs", force: :cascade do |t|
    t.string "username", null: false
    t.string "identification", null: false
    t.string "name", null: false
    t.string "user_type", default: "staff", null: false
    t.string "password_digest"
    t.boolean "active", default: true, null: false
    t.boolean "limited", default: true, null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
  end

  create_table "sync_requests", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value"], name: "index_tags_on_value", unique: true
  end

  create_table "titles", force: :cascade do |t|
    t.string "used_by_model"
    t.bigint "model_id"
    t.string "en"
    t.string "fr"
    t.string "jp"
    t.string "roman", default: "taitoru", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["en", "fr", "jp"], name: "index_titles_on_en_and_fr_and_jp"
    t.index ["en", "used_by_model"], name: "index_titles_on_en_and_used_by_model"
    t.index ["fr", "used_by_model"], name: "index_titles_on_fr_and_used_by_model"
    t.index ["jp", "used_by_model"], name: "index_titles_on_jp_and_used_by_model"
    t.index ["roman"], name: "index_titles_on_roman"
  end

  create_table "uploads", force: :cascade do |t|
    t.bigint "user_id"
    t.string "uuid", null: false
    t.string "upload_type", null: false
    t.string "upload_status", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "user_likes", force: :cascade do |t|
    t.bigint "show_id", null: false
    t.bigint "user_id", null: false
    t.boolean "value", null: false
    t.boolean "is_disabled", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type", null: false
    t.string "token", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "active_until", null: false
    t.datetime "deleted_on"
    t.string "device_id", default: "", null: false
    t.string "device_name", default: "", null: false
    t.string "device_location", default: "", null: false
    t.string "device_os", default: "", null: false
    t.boolean "device_unknown", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deleted", "token"], name: "index_user_sessions_on_deleted_and_token"
    t.index ["token"], name: "index_user_sessions_on_token", unique: true
    t.index ["updated_at"], name: "index_user_sessions_on_updated_at"
    t.index ["user_id", "token"], name: "index_user_sessions_on_user_id_and_token"
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "identification", null: false
    t.string "name", null: false
    t.string "email"
    t.string "user_type", default: "regular", null: false
    t.boolean "active", default: true, null: false
    t.boolean "limited", default: true, null: false
    t.string "hex", default: "#000000", null: false
    t.string "google_token"
    t.string "google_refresh_token"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_refresh_token"], name: "index_users_on_google_refresh_token"
    t.index ["google_token"], name: "index_users_on_google_token"
    t.index ["hex"], name: "index_users_on_hex", unique: true
    t.index ["identification"], name: "index_users_on_identification", unique: true
    t.index ["updated_at"], name: "index_users_on_updated_at"
    t.index ["username", "email"], name: "index_users_on_username_and_email"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "job_events", "staffs"
  add_foreign_key "uploads", "users"
end
