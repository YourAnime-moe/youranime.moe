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

ActiveRecord::Schema.define(version: 2019_02_26_191042) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "allowed_users"
    t.string "path"
    t.boolean "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "episodes", id: :serial, force: :cascade do |t|
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

  create_table "messages", id: :serial, force: :cascade do |t|
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

  create_table "news", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recommendations", id: :serial, force: :cascade do |t|
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

  create_table "shows", id: :serial, force: :cascade do |t|
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
  end

  create_table "todos", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
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
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
  end

end
