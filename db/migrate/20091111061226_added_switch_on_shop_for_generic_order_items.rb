class AddedSwitchOnShopForGenericOrderItems < ActiveRecord::Migration
  def self.up
    add_column :shops, :generic_orders, :boolean, :default => true
  end

  def self.down
    remove_column :shops, :generic_orders
  end
end
