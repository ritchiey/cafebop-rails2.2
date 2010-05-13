class RenamedMinimumForFreeDelivery < ActiveRecord::Migration
  def self.up
    rename_column :shops, :minimum_for_free_delivery, :minimum_for_free_delivery_in_cents
  end

  def self.down
    rename_column :shops, :minimum_for_free_delivery_in_cents, :minimum_for_free_delivery
  end
end
