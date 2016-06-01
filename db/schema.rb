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

ActiveRecord::Schema.define(version: 20160601222345) do

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
    t.text     "name",        null: false
    t.integer  "bgg_game_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "games", ["bgg_game_id"], name: "index_games_on_bgg_game_id", unique: true
  add_index "games", ["name"], name: "index_games_on_name"

  create_table "ownerships", id: false, force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.integer  "player_id",  null: false
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ownerships", ["game_id", "player_id"], name: "index_ownerships_on_game_id_and_player_id", unique: true
  add_index "ownerships", ["game_id"], name: "index_ownerships_on_game_id"
  add_index "ownerships", ["player_id"], name: "index_ownerships_on_player_id"

  create_table "play_wishes", id: false, force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.integer  "player_id",  null: false
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "play_wishes", ["game_id", "player_id"], name: "index_play_wishes_on_game_id_and_player_id", unique: true
  add_index "play_wishes", ["game_id"], name: "index_play_wishes_on_game_id"
  add_index "play_wishes", ["player_id"], name: "index_play_wishes_on_player_id"

  create_table "players", force: :cascade do |t|
    t.text     "bgg_username"
    t.text     "bgg_user_id"
    t.text     "meetup_username"
    t.text     "meetup_link"
    t.text     "meetup_status"
    t.text     "meetup_joined"
    t.integer  "meetup_user_id",          null: false
    t.text     "meetup_bio"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "collection_requested_at"
    t.boolean  "granted"
    t.datetime "collection_processed_at"
    t.datetime "ratings_imported_at"
  end

  add_index "players", ["meetup_user_id"], name: "index_players_on_meetup_user_id", unique: true

  create_table "ratings", force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.integer  "player_id",  null: false
    t.decimal  "rating",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["game_id"], name: "index_ratings_on_game_id"
  add_index "ratings", ["player_id"], name: "index_ratings_on_player_id"

  create_table "rsvps", id: false, force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "event_id",  null: false
    t.text    "response"
  end

  add_index "rsvps", ["event_id", "player_id"], name: "index_rsvps_on_event_id_and_player_id", unique: true

end
