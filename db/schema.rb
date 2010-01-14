# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100114065443) do

  create_table "claims", :force => true do |t|
    t.text     "notes"
    t.string   "state",       :default => "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "shop_id"
    t.integer  "reviewer_id"
    t.string   "first_name"
    t.string   "last_name"
  end

  create_table "cuisine_menus", :force => true do |t|
    t.integer  "cuisine_id"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cuisines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "franchise",  :default => false
    t.string   "url"
  end

  create_table "customer_queues", :force => true do |t|
    t.string   "name",       :default => "Front counter"
    t.boolean  "active",     :default => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flavours", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "menu_item_id"
    t.integer  "position"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_queues", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "position"
    t.boolean  "active",     :default => false
  end

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "price_in_cents"
    t.boolean  "present_flavours", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_queue_id"
    t.integer  "menu_id"
    t.integer  "extras_menu_id"
    t.integer  "position"
  end

  create_table "menu_templates", :force => true do |t|
    t.string   "name"
    t.text     "yaml_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "menus", :force => true do |t|
    t.string   "name"
    t.string   "header"
    t.string   "footer"
    t.boolean  "is_extras"
    t.boolean  "community"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "position"
    t.string   "permalink"
  end

  create_table "operating_times", :force => true do |t|
    t.string   "days"
    t.string   "opens",      :limit => 7
    t.string   "closes",     :limit => 7
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "position"
  end

  create_table "order_items", :force => true do |t|
    t.string   "description"
    t.integer  "quantity"
    t.integer  "price_in_cents"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_queue_id"
    t.integer  "order_id"
    t.integer  "menu_item_id"
    t.integer  "size_id"
    t.integer  "flavour_id"
    t.string   "state",          :default => "pending"
  end

  create_table "orders", :force => true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "shop_id"
    t.integer  "parent_id"
    t.string   "state",             :default => "pending"
    t.string   "perishable_token"
    t.datetime "close_time"
    t.integer  "minutes_til_close"
    t.datetime "paid_at"
    t.integer  "customer_queue_id"
    t.string   "paypal_paykey"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.string   "status"
    t.string   "transaction_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_areas", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "suburb_id"
    t.integer  "shop_id"
  end

  create_table "shop_cuisines", :force => true do |t|
    t.integer  "shop_id"
    t.integer  "cuisine_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                          :default => "community"
    t.float    "lat"
    t.float    "lng"
    t.string   "street_address"
    t.string   "postal_address"
    t.string   "header_background_file_name"
    t.string   "header_background_content_type"
    t.integer  "header_background_file_size"
    t.datetime "header_background_updated_at"
    t.boolean  "accept_queued_orders",           :default => false
    t.boolean  "generic_orders",                 :default => true
    t.integer  "franchise_id"
    t.string   "permalink"
    t.boolean  "accept_paypal_orders",           :default => false
    t.string   "paypal_recipient"
    t.integer  "fee_threshold_in_cents",         :default => 0
    t.integer  "location_accuracy"
  end

  add_index "shops", ["permalink"], :name => "index_shops_on_permalink", :unique => true

  create_table "sizes", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "price_in_cents"
    t.string   "extras_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "menu_item_id"
    t.integer  "position"
  end

  create_table "suburbs", :force => true do |t|
    t.string   "name"
    t.string   "postcode"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lng"
    t.float    "lat"
  end

  create_table "t_and_cs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
    t.boolean  "published"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "perishable_token"
    t.string   "roles",             :default => "--- []"
    t.boolean  "active",            :default => false,    :null => false
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.datetime "current_login_at"
    t.string   "current_login_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "work_contracts", :force => true do |t|
    t.string   "role",       :default => "patron"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
    t.integer  "user_id"
  end

end
