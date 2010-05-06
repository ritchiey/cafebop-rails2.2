class AddedOwnerIdToShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :owner_id, :integer
    remove_column :shops, :creator_email_address
  end

  def self.down
    remove_column :shops, :owner_id
    add_column :shops, :creator_email_address, :string, :limit => 250
  end
end
