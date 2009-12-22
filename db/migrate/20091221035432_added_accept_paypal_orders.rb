class AddedAcceptPaypalOrders < ActiveRecord::Migration
  def self.up
    add_column :shops, :accept_paypal_orders, :boolean, :default => false
  end

  def self.down
    remove_column :shops, :accept_paypal_orders
  end
end
