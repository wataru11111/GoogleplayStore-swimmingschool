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

ActiveRecord::Schema[7.1].define(version: 2025_05_29_031352) do
  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "children", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.string "last_name", null: false
    t.string "first_name", null: false
    t.string "last_name_kana", null: false
    t.string "first_name_kana", null: false
    t.string "level", null: false
    t.string "telephone_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_dey1"
    t.string "contact_dey2"
    t.string "contact_time1"
    t.string "contact_time2"
  end

  create_table "customers", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "last_name_kana"
    t.string "first_name_kana"
    t.string "postal_code"
    t.string "address"
    t.string "telephone_number"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "status", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
  end

  create_table "offs", force: :cascade do |t|
    t.date "off_month"
    t.date "off_day"
    t.integer "child_id", null: false
    t.string "level", null: false
    t.integer "flag", null: false
    t.string "last_name", null: false
    t.string "first_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_time1"
    t.string "contact_time2"
    t.string "contact_dey1"
    t.string "contact_dey2"
    t.index ["child_id", "off_day"], name: "index_offs_on_child_id_and_off_day", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "child_id", null: false
    t.integer "off_id", null: false
    t.string "last_name", null: false
    t.string "first_name", null: false
    t.date "transfer_date", null: false
    t.string "transfer_time", null: false
    t.string "telephone_number"
    t.string "level", null: false
    t.string "contact_dey", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
