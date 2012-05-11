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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120511023550) do

  create_table "codes", :force => true do |t|
    t.integer  "location_id"
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                   :null => false
    t.string   "password",                                :null => false
    t.string   "role",              :default => "user",   :null => false
    t.string   "name",                                    :null => false
    t.string   "email",                                   :null => false
    t.string   "address",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rate_type",         :default => "hourly", :null => false
    t.integer  "rate_amount_cents", :default => 0,        :null => false
    t.string   "invoice_recipient"
  end

  create_table "work_entries", :force => true do |t|
    t.integer  "code_id"
    t.date     "worked_at"
    t.integer  "minutes"
    t.integer  "rate_cents"
    t.integer  "fee_cents"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    :default => 2, :null => false
  end

end
