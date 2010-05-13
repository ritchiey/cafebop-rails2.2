class DeliveryFees < ActiveRecord::Migration
  def self.up
    add_column :shops, :delivery_fee_in_cents, :integer, :default => 500
    add_column :shops, :minimum_for_free_delivery, :integer, :default => 2500
  end

  def self.down
    remove_column :shops, :delivery_fee_in_cents
    remove_column :shops, :minimum_for_free_delivery
  end
end
