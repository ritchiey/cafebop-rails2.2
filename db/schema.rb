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

ActiveRecord::Schema.define(:version => 20091020025232) do

  create_table "claims", :force => true do |t|
    t.text     "notes"
    t.string   "state",       :default => "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "shop_id"
    t.integer  "reviewer_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "friend_id"
  end

  create_table "item_queues", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
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
  end

  create_table "operating_times", :force => true do |t|
    t.string   "days"
    t.string   "opens",      :limit => 7
    t.string   "closes",     :limit => 7
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shop_id"
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
    t.string   "state",      :default => "pending"
  end

  create_table "service_areas", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "suburb_id"
    t.integer  "shop_id"
  end

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",         :default => "community"
  end

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
