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

ActiveRecord::Schema[8.0].define(version: 2025_08_22_053733) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointment_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "slot_id", null: false
    t.bigint "appointment_type_id", null: false
    t.string "name", null: false
    t.string "furigana", null: false
    t.string "phone", null: false
    t.string "email"
    t.integer "party_size", default: 1, null: false
    t.text "purpose"
    t.text "notes"
    t.boolean "accept_privacy", default: false, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_type_id"], name: "index_appointments_on_appointment_type_id"
    t.index ["branch_id"], name: "index_appointments_on_branch_id"
    t.index ["phone", "slot_id"], name: "index_appointments_on_phone_and_slot_id", unique: true
    t.index ["slot_id"], name: "index_appointments_on_slot_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branches", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.string "name"
    t.string "address"
    t.string "phone"
    t.text "open_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_branches_on_area_id"
  end

  create_table "slots", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "capacity", default: 1, null: false
    t.integer "booked_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id", "starts_at"], name: "index_slots_on_branch_id_and_starts_at", unique: true
    t.index ["branch_id"], name: "index_slots_on_branch_id"
  end

  add_foreign_key "appointments", "appointment_types"
  add_foreign_key "appointments", "branches"
  add_foreign_key "appointments", "slots"
  add_foreign_key "branches", "areas"
  add_foreign_key "slots", "branches"
end
