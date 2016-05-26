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

ActiveRecord::Schema.define(version: 20160526152523) do

  create_table "events", force: :cascade do |t|
    t.text     "meetup_event_id"
    t.text     "name"
    t.text     "provided_url"
    t.text     "status"
    t.datetime "event_time"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "events", ["meetup_event_id"], name: "index_events_on_meetup_event_id", unique: true

  create_table "games", force: :cascade do |t|
    t.text     "name"
    t.integer  "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "games", ["game_id"], name: "index_games_on_game_id", unique: true

  create_table "ownerships", id: false, force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "meetup_user_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "play_wishes", id: false, force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "meetup_user_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: :cascade do |t|
    t.text     "bgg_username"
    t.text     "bgg_user_id"
    t.text     "meetup_username"
    t.text     "meetup_link"
    t.text     "meetup_status"
    t.text     "meetup_joined"
    t.integer  "meetup_user_id"
    t.text     "meetup_bio"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "last_collection_request_time"
    t.boolean  "granted"
    t.datetime "collection_processed_at"
  end

  add_index "players", ["meetup_user_id"], name: "index_players_on_meetup_user_id", unique: true

  create_table "rsvps", id: false, force: :cascade do |t|
    t.integer "meetup_user_id"
    t.integer "meetup_event_id"
    t.text    "response"
  end

end
