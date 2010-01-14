class DroppedLoginCountsOnUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :failed_login_count
    remove_column :users, :login_count
  end

  def self.down
    add_column :users, :failed_login_count, :integer, :default => 0,        :null => false
    add_column :users, :login_count, :integer, :default => 0,        :null => false
  end
end
