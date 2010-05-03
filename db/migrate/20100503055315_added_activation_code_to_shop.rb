class AddedActivationCodeToShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :activation_code, :string, :limit => 20
  end

  def self.down
    remove_column :shops, :activation_code
  end
end
