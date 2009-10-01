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

ActiveRecord::Schema.define(:version => 20090930080754) do

  create_table "flavours", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "menu_item_id"
  end

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "price"
    t.boolean  "present_flavours", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_queue_id"
    t.integer  "menu_id"
    t.integer  "extras_menu_id"
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

  create_table "order_items", :force => true do |t|
    t.string   "description"
    t.integer  "quantity"
    t.integer  "price"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_queue_id"
    t.integer  "order_id"
    t.integer  "menu_item_id"
    t.integer  "size_id"
    t.integer  "flavour_id"
  end

  create_table "orders", :force => true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "shop_id"
    t.integer  "parent_id"
  end

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sizes", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "price"
    t.string   "extras_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "menu_item_id"
  end

end
