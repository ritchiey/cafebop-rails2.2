class AddShortnameForShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :shortname, :string
    add_index :shops, [:shortname], :unique => true
  end

  def self.down
    remove_index :shops, :column => [:shortname]
    remove_column :shops, :shortname
  end
end
