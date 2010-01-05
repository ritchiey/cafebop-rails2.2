class DropPaypalRecipient < ActiveRecord::Migration
  def self.up
    remove_column :orders, :paypal_recipient
    
    change_column :shops, :fee_threshold_in_cents, :integer, :default => 1500
  end

  def self.down
    add_column :orders, :paypal_recipient, :string
    
    change_column :shops, :fee_threshold_in_cents, :integer
  end
end
