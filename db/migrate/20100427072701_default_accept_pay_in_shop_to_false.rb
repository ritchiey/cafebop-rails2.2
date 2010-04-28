class DefaultAcceptPayInShopToFalse < ActiveRecord::Migration
  def self.up
    change_column :shops, :accept_pay_in_shop, :boolean, :default => false
  end

  def self.down
    change_column :shops, :accept_pay_in_shop, :boolean, :default => true
  end
end
