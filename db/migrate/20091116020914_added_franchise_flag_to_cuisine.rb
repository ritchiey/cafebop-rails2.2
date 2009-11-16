class AddedFranchiseFlagToCuisine < ActiveRecord::Migration
  def self.up
    add_column :cuisines, :franchise, :boolean, :default => false
  end

  def self.down
    remove_column :cuisines, :franchise
  end
end
