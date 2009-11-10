class AddQueueActivationFlags < ActiveRecord::Migration
  def self.up
    add_column :item_queues, :active, :boolean, :default => false
    
    add_column :shops, :accept_queued_orders, :boolean, :default => false
  end

  def self.down
    remove_column :item_queues, :active
    
    remove_column :shops, :accept_queued_orders
  end
end
