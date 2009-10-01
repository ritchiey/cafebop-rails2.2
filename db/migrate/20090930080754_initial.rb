class Initial < ActiveRecord::Migration
  def self.up
    create_table :sizes do |t|
      t.string   :name
      t.string   :description
      t.integer  :price
      t.string   :extras_price
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :menu_item_id
    end
    
    create_table :menu_items do |t|
      t.string   :name
      t.string   :description
      t.integer  :price
      t.boolean  :present_flavours, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :item_queue_id
      t.integer  :menu_id
      t.integer  :extras_menu_id
    end
    
    create_table :flavours do |t|
      t.string   :name
      t.string   :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :menu_item_id
    end
    
    create_table :orders do |t|
      t.text     :notes
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :shop_id
      t.integer  :parent_id
    end
    
    create_table :menus do |t|
      t.string   :name
      t.string   :header
      t.string   :footer
      t.boolean  :is_extras
      t.boolean  :community
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :shop_id
    end
    
    create_table :order_items do |t|
      t.string   :description
      t.integer  :quantity
      t.integer  :price
      t.string   :notes
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :item_queue_id
      t.integer  :order_id
      t.integer  :menu_item_id
      t.integer  :size_id
      t.integer  :flavour_id
    end
    
    create_table :shops do |t|
      t.string   :name
      t.string   :phone
      t.string   :fax
      t.string   :website
      t.string   :email_address
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :sizes
    drop_table :menu_items
    drop_table :flavours
    drop_table :orders
    drop_table :menus
    drop_table :order_items
    drop_table :shops
  end
end
