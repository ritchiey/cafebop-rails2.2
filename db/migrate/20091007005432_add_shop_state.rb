class AddShopState < ActiveRecord::Migration
  def self.up
    add_column :shops, :state, :string
  end

  def self.down
    remove_column :shops, :state
  end
end
