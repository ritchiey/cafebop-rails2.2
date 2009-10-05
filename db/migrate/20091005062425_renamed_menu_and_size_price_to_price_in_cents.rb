class RenamedMenuAndSizePriceToPriceInCents < ActiveRecord::Migration
  def self.up
    rename_column :sizes, :price, :price_in_cents
    
    rename_column :menu_items, :price, :price_in_cents
  end

  def self.down
    rename_column :sizes, :price_in_cents, :price
    
    rename_column :menu_items, :price_in_cents, :price
  end
end
