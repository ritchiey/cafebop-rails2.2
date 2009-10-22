class SetDefaultValueToUserActive < ActiveRecord::Migration
  def self.up
    change_column :users, :active, :boolean, :null => true, :default => false
  end

  def self.down
    change_column :users, :active, :boolean, :default => false,    :null => false
  end
end
