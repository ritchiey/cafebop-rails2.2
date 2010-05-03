class AddCreatorEmailAddressToShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :creator_email_address, :string, :limit => 250
  end

  def self.down
    remove_column :shops, :creator_email_address
  end
end
