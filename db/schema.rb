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

ActiveRecord::Schema.define(version: 2019_06_24_190901) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "scryfall_id"
    t.string "name"
    t.string "image_uris"
    t.string "mana_cost"
    t.integer "cmc"
    t.string "oracle_text"
    t.string "colors"
    t.string "color_identity"
    t.string "legalities"
    t.string "prices"
    t.string "types"
    t.string "subtypes"
  end

  create_table "deck_cards", force: :cascade do |t|
    t.integer "card_id"
    t.integer "deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id"
    t.integer "deck_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.string "favorite_card_id"
    t.string "image"
  end

end
