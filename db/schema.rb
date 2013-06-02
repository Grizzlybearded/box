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

ActiveRecord::Schema.define(:version => 20130601220420) do

  create_table "funds", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "fund_type"
    t.boolean  "bmark",        :default => false
    t.boolean  "core_bmark",   :default => false
    t.boolean  "retired",      :default => false
    t.boolean  "starter_fund", :default => false
  end

  create_table "investors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "invitation_id"
  end

  add_index "investors", ["name"], :name => "index_investors_on_name", :unique => true

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "invite_type",     :default => false
  end

  create_table "months", :force => true do |t|
    t.date     "mend"
    t.integer  "fund_id"
    t.decimal  "fund_return", :precision => 6, :scale => 4
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "months", ["mend", "fund_id"], :name => "index_months_on_mend_and_fund_id", :unique => true

  create_table "relationships", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "investor_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["fund_id", "investor_id"], :name => "index_relationships_on_fund_id_and_investor_id", :unique => true

  create_table "trackers", :force => true do |t|
    t.integer  "fund_id"
    t.integer  "benchmark_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "user_id"
  end

  add_index "trackers", ["fund_id", "benchmark_id", "user_id"], :name => "index_trackers_on_fund_id_and_benchmark_id_and_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "name"
    t.boolean  "global_admin",           :default => false
    t.integer  "investor_id"
    t.integer  "invitation_id"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
