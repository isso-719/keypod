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

ActiveRecord::Schema.define(version: 2020_05_27_004514) do

  create_table "keys", force: :cascade do |t|
    t.integer "workspace_id"
    t.string "key"
    t.string "path"
    t.string "description"
    t.string "data_type"
    t.index ["workspace_id"], name: "index_keys_on_workspace_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "mail"
    t.string "password_digest"
  end

  create_table "workspaces", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "url"
    t.index ["user_id"], name: "index_workspaces_on_user_id"
  end

end