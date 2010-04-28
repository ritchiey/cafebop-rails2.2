class DropAcceptQueuedOrders < ActiveRecord::Migration
  def self.up
    remove_column :shops, :accept_queued_orders
  end

  def self.down
    add_column :shops, :accept_queued_orders, :boolean, :default => false
  end
end
