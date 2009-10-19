class SetStateDefaultToClaim < ActiveRecord::Migration
  def self.up
    change_column :claims, :state, :string, :limit => 255, :default => "pending"
  end

  def self.down
    change_column :claims, :state, :string
  end
end
