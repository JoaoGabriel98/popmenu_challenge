# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_30_235514) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "menu_itemizations", force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "menu_item_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id", "menu_item_id"], name: "index_menu_itemizations_on_menu_id_and_menu_item_id", unique: true
    t.index ["menu_id"], name: "index_menu_itemizations_on_menu_id"
    t.index ["menu_item_id"], name: "index_menu_itemizations_on_menu_item_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "restaurant_id", null: false
    t.index ["available"], name: "index_menu_items_on_available"
    t.index ["restaurant_id", "name"], name: "index_menu_items_on_restaurant_id_and_name", unique: true
    t.index ["restaurant_id"], name: "index_menu_items_on_restaurant_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "restaurant_id", null: false
    t.index ["name"], name: "index_menus_on_name"
    t.index ["restaurant_id", "name"], name: "index_menus_on_restaurant_id_and_name", unique: true
    t.index ["restaurant_id"], name: "index_menus_on_restaurant_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_restaurants_on_slug", unique: true
  end

  add_foreign_key "menu_itemizations", "menu_items"
  add_foreign_key "menu_itemizations", "menus"
  add_foreign_key "menu_items", "restaurants"
  add_foreign_key "menus", "restaurants"
end
