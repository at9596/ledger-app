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

ActiveRecord::Schema[8.1].define(version: 2026_02_19_035940) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "account_type", null: false
    t.decimal "balance", precision: 19, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.decimal "amount", precision: 19, scale: 4, null: false
    t.datetime "created_at", null: false
    t.bigint "ledger_transaction_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_entries_on_account_id"
    t.index ["ledger_transaction_id"], name: "index_entries_on_ledger_transaction_id"
    t.check_constraint "amount <> 0::numeric", name: "amount_nonzero"
  end

  create_table "ledger_transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "idempotency_key"
    t.jsonb "metadata"
    t.datetime "updated_at", null: false
    t.index ["idempotency_key"], name: "index_ledger_transactions_on_idempotency_key", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "entries", "accounts"
  add_foreign_key "entries", "ledger_transactions"
  add_foreign_key "sessions", "users"
end
