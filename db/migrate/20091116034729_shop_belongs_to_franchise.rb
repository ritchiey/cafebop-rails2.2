class ShopBelongsToFranchise < ActiveRecord::Migration
  def self.up
    add_column :shops, :franchise_id, :integer
  end

  def self.down
    remove_column :shops, :franchise_id
  end
end
