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

ActiveRecord::Schema.define(version: 2019_08_10_003936) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "shows_queues", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.string "username", null: false
    t.string "identification", null: false
    t.string "name", null: false
    t.string "user_type", default: "staff", null: false
    t.boolean "active", default: true, null: false
    t.boolean "limited", default: true, null: false
    t.integer "user_id"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["identification"], name: "index_users_on_identification", unique: true
    t.index ["updated_at"], name: "index_users_on_updated_at"
    t.index ["username", "email"], name: "index_users_on_username_and_email"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
