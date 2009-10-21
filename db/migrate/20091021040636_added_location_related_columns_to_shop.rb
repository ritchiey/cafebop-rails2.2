class AddedLocationRelatedColumnsToShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :street, :string
    add_column :shops, :suburb, :string
    add_column :shops, :province, :string
    add_column :shops, :country, :string
    add_column :shops, :postcode, :string
  end

  def self.down
    remove_column :shops, :street
    remove_column :shops, :suburb
    remove_column :shops, :province
    remove_column :shops, :country
    remove_column :shops, :postcode
  end
end
