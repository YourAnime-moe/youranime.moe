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

ActiveRecord::Schema.define(version: 2019_09_13_190129) do

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

  create_table "actors", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "label"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.text "plot", default: "", null: false
    t.date "released_on", null: false
    t.date "published_on"
    t.boolean "featured", default: false, null: false
    t.boolean "recommended", default: false, null: false
    t.string "banner_url", default: "/img/404.jpg", null: false
    t.integer "queue_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["banner_url"], name: "index_shows_on_banner_url"
  end

  create_table "shows_queue_relations", force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "queue_id", null: false
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

  create_table "tags", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
