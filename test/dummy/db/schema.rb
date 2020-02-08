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

ActiveRecord::Schema.define(version: 2019_06_30_084138) do

  create_table "members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "remarks"
    t.date "birthday"
    t.bigint "pref_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pref_id"], name: "index_members_on_pref_id"
  end

  create_table "prefs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_models", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "string_test"
    t.text "text_test"
    t.integer "integer_test"
    t.float "float_test"
    t.decimal "decimal_test", precision: 10
    t.datetime "datetime_test"
    t.timestamp "timestamp_test"
    t.time "time_test"
    t.date "date_test"
    t.binary "binary_test"
    t.boolean "boolean_test"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.column "enum_test", "enum('enum1','enum2','enum3')", null: false
  end

end
