class DefaultPriceInCentsOfAnOrderItemTo100 < ActiveRecord::Migration
  def self.up
    change_column :menu_items, :price_in_cents, :integer, :default => 100
  end

  def self.down
    change_column :menu_items, :price_in_cents, :integer
  end
end
