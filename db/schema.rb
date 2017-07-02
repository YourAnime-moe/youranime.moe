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

ActiveRecord::Schema.define(version: 20170702014447) do

  create_table "episodes", force: :cascade do |t|
    t.integer  "show_id"
    t.string   "op"
    t.string   "ed"
    t.integer  "previous_id"
    t.integer  "next_id"
    t.string   "path"
    t.string   "title"
    t.integer  "episode_number"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "published"
    t.string   "comments"
  end

  create_table "news", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "recommendations", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.text     "plot"
    t.integer  "show_type"
    t.boolean  "dubbed"
    t.string   "ref_link"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "from_user"
  end

  create_table "shows", force: :cascade do |t|
    t.integer  "show_type"
    t.boolean  "dubbed"
    t.boolean  "subbed"
    t.string   "starring"
    t.boolean  "movie"
    t.float    "average_run_time"
    t.integer  "show_number"
    t.text     "plot"
    t.text     "review"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "year"
    t.string   "title"
    t.string   "alternate_title"
    t.boolean  "published"
    t.string   "default_path"
    t.string   "image_path"
    t.string   "description"
    t.boolean  "featured"
    t.boolean  "recommended"
    t.integer  "season_year"
    t.integer  "season_code"
    t.string   "tags"
  end

  create_table "todos", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.string   "password_digest"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "name"
    t.boolean  "admin"
    t.string   "episodes_watched"
    t.string   "settings"
    t.string   "auth_token"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
  end

end
