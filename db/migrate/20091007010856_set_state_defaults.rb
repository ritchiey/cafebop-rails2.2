class SetStateDefaults < ActiveRecord::Migration
  def self.up
    change_column :orders, :state, :string, :default => "pending", :limit => 255
    
    change_column :order_items, :state, :string, :default => "pending", :limit => 255
    
    change_column :shops, :state, :string, :default => "community", :limit => 255
  end

  def self.down
    change_column :orders, :state, :string
    
    change_column :order_items, :state, :string
    
    change_column :shops, :state, :string
  end
end
