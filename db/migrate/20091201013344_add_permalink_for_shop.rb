class AddPermalinkForShop < ActiveRecord::Migration
  def self.up
    add_column :shops, :permalink, :string
    add_index :shops, [:permalink], :unique => true
  end

  def self.down
    remove_index :shops, :column => [:permalink]
    remove_column :shops, :permalink
  end
end
