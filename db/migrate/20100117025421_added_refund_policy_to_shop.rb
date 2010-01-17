class AddedRefundPolicyToShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :refund_policy, :text
    add_column :shops, :motto, :text
  end

  def self.down
    remove_column :shops, :refund_policy
    remove_column :shops, :motto
  end
end
