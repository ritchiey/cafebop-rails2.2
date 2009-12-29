class AddedShopFieldsForPaypal < ActiveRecord::Migration
  def self.up
    add_column :orders, :paypal_recipient, :string
    
    add_column :shops, :paypal_recipient, :string
    add_column :shops, :fee_threshold_in_cents, :integer
  end

  def self.down
    remove_column :orders, :paypal_recipient
    
    remove_column :shops, :paypal_recipient
    remove_column :shops, :fee_threshold_in_cents
  end
end
