class ExtraShopFields < ActiveRecord::Migration
  def self.up
    add_column :shops, :accept_pay_in_shop, :boolean, :default => true
    add_column :shops, :shop_discount, :float
  end

  def self.down
    remove_column :shops, :accept_pay_in_shop
    remove_column :shops, :shop_discount
  end
end
