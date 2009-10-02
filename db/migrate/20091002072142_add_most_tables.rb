class AddMostTables < ActiveRecord::Migration
  def self.up
    create_table :work_contracts do |t|
      t.string   :role, :default => "patron"
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :shop_id
      t.integer  :user_id
    end
    
    create_table :service_areas do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :suburb_id
      t.integer  :shop_id
    end
    
    create_table :item_queues do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :shop_id
    end
    
    create_table :friendships do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :friend_id
    end
    
    create_table :t_and_cs do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.text     :body
      t.boolean  :published
    end
    
    create_table :suburbs do |t|
      t.string   :name
      t.string   :postcode
      t.string   :state
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    create_table :operating_times do |t|
      t.string   :days
      t.string   :opens, :limit => 7
      t.string   :closes, :limit => 7
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :shop_id
    end
    
    add_column :claims, :notes, :text
    add_column :claims, :state, :string
    add_column :claims, :created_at, :datetime
    add_column :claims, :updated_at, :datetime
    add_column :claims, :user_id, :integer
    add_column :claims, :shop_id, :integer
    add_column :claims, :reviewer_id, :integer
    
    add_column :orders, :state, :string
    
    add_column :order_items, :state, :string
  end

  def self.down
    remove_column :claims, :notes
    remove_column :claims, :state
    remove_column :claims, :created_at
    remove_column :claims, :updated_at
    remove_column :claims, :user_id
    remove_column :claims, :shop_id
    remove_column :claims, :reviewer_id
    
    remove_column :orders, :state
    
    remove_column :order_items, :state
    
    drop_table :work_contracts
    drop_table :service_areas
    drop_table :item_queues
    drop_table :friendships
    drop_table :t_and_cs
    drop_table :suburbs
    drop_table :operating_times
  end
end
