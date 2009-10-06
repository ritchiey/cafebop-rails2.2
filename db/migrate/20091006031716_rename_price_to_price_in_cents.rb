class RenamePriceToPriceInCents < ActiveRecord::Migration
  def self.up
    rename_column :order_items, :price, :price_in_cents
  end

  def self.down
    rename_column :order_items, :price_in_cents, :price
  end
end
