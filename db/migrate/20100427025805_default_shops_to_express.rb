class DefaultShopsToExpress < ActiveRecord::Migration
  def self.up
    change_column :shops, :state, :string, :default => "express", :limit => 20
  end

  def self.down
    change_column :shops, :state, :string, :default => "community"
  end
end
