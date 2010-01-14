class AddedPaypalPaykeyToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :paypal_paykey, :string
  end

  def self.down
    remove_column :orders, :paypal_paykey
  end
end
