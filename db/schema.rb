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

ActiveRecord::Schema.define(version: 2019_03_04_000149) do

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

  create_table "episodes", force: :cascade do |t|
    t.integer "show_id"
    t.string "op"
    t.string "ed"
    t.integer "previous_id"
    t.integer "next_id"
    t.string "path"
    t.string "title"
    t.integer "episode_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published"
    t.string "comments"
  end

  create_table "issues", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "resolved"
    t.boolean "open"
    t.string "page_url"
    t.text "screenshots"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "subject"
    t.integer "from_id"
    t.integer "to_id"
    t.boolean "from_flag"
    t.boolean "from_read"
    t.boolean "to_read"
    t.text "content"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recommendations", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "plot"
    t.integer "show_type"
    t.boolean "dubbed"
    t.string "ref_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_user"
  end

  create_table "shows", force: :cascade do |t|
    t.integer "show_type"
    t.boolean "dubbed"
    t.boolean "subbed"
    t.string "starring"
    t.boolean "movie"
    t.float "average_run_time"
    t.integer "show_number"
    t.text "plot"
    t.text "review"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.string "title"
    t.string "alternate_title"
    t.boolean "published"
    t.string "default_path"
    t.string "image_path"
    t.string "description"
    t.boolean "featured"
    t.boolean "recommended"
    t.integer "season_year"
    t.integer "season_code"
    t.string "tags"
    t.date "publish_after"
    t.date "published_until"
    t.string "jp_title"
    t.string "fr_title"
    t.string "roman_title"
    t.text "jp_description"
    t.text "fr_description"
  end

  create_table "todos", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_favorites", force: :cascade do |t|
    t.integer "show_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_queues", force: :cascade do |t|
    t.integer "user_id"
    t.integer "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_watch_progresses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "episode_id"
    t.float "progress"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "admin"
    t.string "episodes_watched"
    t.string "settings"
    t.string "auth_token"
    t.boolean "is_activated"
    t.boolean "demo"
    t.string "episode_progress_list"
    t.string "avatar"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
  end

end
