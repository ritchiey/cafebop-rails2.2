class AddedLocationRelatedColumnsToShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :street_address, :string
    add_column :shops, :postal_address, :string
  end

  def self.down
    remove_column :shops, :street_address
    remove_column :shops, :postal_address
  end
end
